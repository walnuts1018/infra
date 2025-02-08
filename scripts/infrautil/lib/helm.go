package lib

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net/url"
	"os"
	"strings"

	"helm.sh/helm/v3/pkg/action"
	"helm.sh/helm/v3/pkg/chart"
	"helm.sh/helm/v3/pkg/chart/loader"
	"helm.sh/helm/v3/pkg/cli"
	"helm.sh/helm/v3/pkg/downloader"
	"helm.sh/helm/v3/pkg/getter"
	"helm.sh/helm/v3/pkg/registry"
	"helm.sh/helm/v3/pkg/release"
	"sigs.k8s.io/yaml"
)

type HelmClient struct {
	cfg      *action.Configuration
	settings *cli.EnvSettings
	client   *action.Install
}

func NewHelmClient() (*HelmClient, error) {
	cfg := new(action.Configuration)
	settings := cli.New()

	registryClient, err := newRegistryClient(settings)
	if err != nil {
		return nil, err
	}
	cfg.RegistryClient = registryClient

	client := action.NewInstall(cfg)
	client.DryRun = true
	client.DryRunOption = "true"
	client.Replace = true
	client.ClientOnly = true
	client.IncludeCRDs = true

	return &HelmClient{
		cfg:      cfg,
		settings: settings,
		client:   client,
	}, nil
}

func newRegistryClient(settings *cli.EnvSettings) (*registry.Client, error) {
	return registry.NewClient(
		registry.ClientOptDebug(false),
		registry.ClientOptEnableCache(true),
		registry.ClientOptWriter(os.Stderr),
		registry.ClientOptCredentialsFile(settings.RegistryConfig),
	)
}

func (h *HelmClient) HelmTemplate(
	ctx context.Context,
	name string,
	namespace string,
	repoURL url.URL,
	chartName string,
	chartVersion string,

	valuesString string,
	valuesObject map[string]interface{},
) (io.Reader, error) {
	registryClient, err := newRegistryClient(h.settings)
	if err != nil {
		return nil, fmt.Errorf("missing registry client: %w", err)
	}
	h.client.SetRegistryClient(registryClient)

	rel, err := h.createRelease(ctx, name, namespace, repoURL, chartName, chartVersion, valuesString, valuesObject)
	if err != nil {
		return nil, fmt.Errorf("failed to create release: %w", err)
	}
	if rel == nil {
		return nil, errors.New("no release created")
	}

	manifests := new(bytes.Buffer)
	fmt.Fprintln(manifests, strings.TrimSpace(rel.Manifest))
	for _, m := range rel.Hooks {
		fmt.Fprintf(manifests, "---\n# Source: %s\n%s\n", m.Path, m.Manifest)
	}

	return manifests, nil
}

func (h *HelmClient) createRelease(
	ctx context.Context,
	name string,
	namespace string,

	repoURL url.URL,

	chartName string,
	chartVersion string,

	valuesString string,
	valuesObject map[string]interface{},
) (*release.Release, error) {
	h.client.ReleaseName = name
	if namespace == "" {
		namespace = "default"
	} else {
		h.client.Namespace = namespace
	}
	h.client.Version = chartVersion

	if isHelmOciRepo(repoURL.String()) {
		repoURL.Scheme = "oci"
		chartName = repoURL.JoinPath(chartName).String()
	} else {
		h.client.ChartPathOptions.RepoURL = repoURL.String()
	}

	cp, err := h.client.ChartPathOptions.LocateChart(chartName, h.settings)
	if err != nil {
		return nil, fmt.Errorf("failed to locate chart: %w", err)
	}

	vals, err := createValues(valuesString, valuesObject)
	if err != nil {
		return nil, fmt.Errorf("failed to create values: %w", err)
	}

	// Check chart dependencies to make sure all are present in /charts
	chartRequested, err := loader.Load(cp)
	if err != nil {
		return nil, fmt.Errorf("failed to load chart: %w", err)
	}

	if err := checkIfInstallable(chartRequested); err != nil {
		return nil, fmt.Errorf("failed to check if chart is installable: %w", err)
	}

	if chartRequested.Metadata.Deprecated {
		slog.Warn("This chart is deprecated")
	}

	if req := chartRequested.Metadata.Dependencies; req != nil {
		// If CheckDependencies returns an error, we have unfulfilled dependencies.
		// As of Helm 2.4.0, this is treated as a stopping condition:
		// https://github.com/helm/helm/issues/2209
		if err := action.CheckDependencies(chartRequested, req); err != nil {
			err = fmt.Errorf("An error occurred while checking for chart dependencies. You may need to run `helm dependency build` to fetch missing dependencies: %w", err)
			if h.client.DependencyUpdate {
				man := &downloader.Manager{
					Out:              os.Stdout,
					ChartPath:        cp,
					Keyring:          h.client.ChartPathOptions.Keyring,
					SkipUpdate:       false,
					Getters:          getter.All(h.settings),
					RepositoryConfig: h.settings.RepositoryConfig,
					RepositoryCache:  h.settings.RepositoryCache,
					Debug:            h.settings.Debug,
					RegistryClient:   h.client.GetRegistryClient(),
				}
				if err := man.Update(); err != nil {
					return nil, fmt.Errorf("failed to update chart dependencies: %w", err)
				}
				// Reload the chart with the updated Chart.lock file.
				if chartRequested, err = loader.Load(cp); err != nil {
					return nil, fmt.Errorf("failed to reload chart after repo update: %w", err)
				}
			} else {
				return nil, err
			}
		}
	}

	// to skip validation
	chartRequested.Metadata.KubeVersion = ""

	release, err := h.client.RunWithContext(ctx, chartRequested, vals)
	if err != nil {
		return nil, fmt.Errorf("failed to run with context: %w", err)
	}
	return release, nil
}

// parameters > valuesObject > values > valueFiles > helm repository values.yaml
func createValues(valuesString string, valuesObject map[string]interface{}) (map[string]interface{}, error) {
	result := make(map[string]interface{})
	if valuesString != "" {
		currentMap := map[string]interface{}{}
		if err := yaml.Unmarshal([]byte(valuesString), &currentMap); err != nil {
			return nil, fmt.Errorf("failed to parse values string: %w", err)
		}
		result = mergeMaps(result, currentMap)
	}

	if valuesObject != nil {
		result = mergeMaps(result, valuesObject)
	}

	return result, nil
}

// from https://github.com/helm/helm/blob/2aba8a1fcd5bb67b35746897a0864ff553edc11f/pkg/cli/values/options.go#L108-L125
func mergeMaps(a, b map[string]interface{}) map[string]interface{} {
	out := make(map[string]interface{}, len(a))
	for k, v := range a {
		out[k] = v
	}
	for k, v := range b {
		if v, ok := v.(map[string]interface{}); ok {
			if bv, ok := out[k]; ok {
				if bv, ok := bv.(map[string]interface{}); ok {
					out[k] = mergeMaps(bv, v)
					continue
				}
			}
		}
		out[k] = v
	}
	return out
}

// from https://github.com/helm/helm/blob/2aba8a1fcd5bb67b35746897a0864ff553edc11f/cmd/helm/install.go#L322-L329
func checkIfInstallable(ch *chart.Chart) error {
	switch ch.Metadata.Type {
	case "", "application":
		return nil
	}
	return fmt.Errorf("%s charts are not installable", ch.Metadata.Type)
}

// From: https://github.com/argoproj/argo-cd/blob/db8d2f08d926c9f811a3d4f26d2883856e135e38/util/helm/client.go#L397-L404
func isHelmOciRepo(repoURL string) bool {
	if repoURL == "" {
		return false
	}
	parsed, err := url.Parse(repoURL)
	// the URL parser treat hostname as either path or opaque if scheme is not specified, so hostname must be empty
	return err == nil && parsed.Host == ""
}
