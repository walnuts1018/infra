package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"io"
	"io/fs"
	"log/slog"
	"net/url"
	"os"
	"path/filepath"

	"github.com/google/subcommands"
	"github.com/walnuts1018/infra/.github/scripts/infrautil/lib"
	"golang.org/x/sync/errgroup"
)

type helmSnapshotCmd struct {
	appSnapshotDir string
	outFileDir     string
}

func (*helmSnapshotCmd) Name() string     { return "helm-snapshot" }
func (*helmSnapshotCmd) Synopsis() string { return "create snapshot" }
func (*helmSnapshotCmd) Usage() string {
	return `helm-snapshot -d <apps snapshot dir> -o <output dir>:`
}

func (b *helmSnapshotCmd) SetFlags(f *flag.FlagSet) {
	f.StringVar(&b.appSnapshotDir, "d", "k8s/snapshot/apps", "app snapshot directory")
	f.StringVar(&b.outFileDir, "o", "k8s/snapshots/helm", "output file path")
}

func (b *helmSnapshotCmd) Execute(_ context.Context, f *flag.FlagSet, _ ...any) subcommands.ExitStatus {
	if err := os.RemoveAll(b.outFileDir); err != nil {
		slog.Error("failed to remove out file path", slog.String("outFileDir", b.outFileDir), slog.Any("error", err))
		return subcommands.ExitFailure
	}

	if err := os.MkdirAll(filepath.Join(b.outFileDir), 0755); err != nil {
		slog.Error("failed to create output directory", slog.String("outFileDir", b.outFileDir), slog.Any("error", err))
		return subcommands.ExitFailure
	}

	eg := new(errgroup.Group)

	if err := filepath.Walk(b.appSnapshotDir, func(path string, info fs.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if info.IsDir() {
			return nil
		}

		if filepath.Ext(path) != ".yaml" {
			return nil
		}

		yamlFile, err := os.Open(path)
		if err != nil {
			slog.Error("failed to open file", slog.String("path", path), slog.Any("error", err))
			return fmt.Errorf("failed to open file: %w", err)
		}

		helmapps, err := lib.ParseHelmApplications(yamlFile)
		if err != nil {
			slog.Error("failed to parse helm application", slog.String("path", path), slog.Any("error", err))
			return fmt.Errorf("failed to parse helm application: %w", err)
		}

		for helmapp, err := range helmapps {
			if err != nil {
				if errors.Is(err, lib.ErrNotHelmApplication) {
					slog.Warn("not a helm application", slog.String("path", path), slog.Any("error", err))
					continue
				}
				return fmt.Errorf("failed to parse helm application: %w", err)
			}

			repoURL, err := url.Parse(helmapp.Spec.Source.RepoURL)
			if err != nil {
				slog.Error("failed to parse repo url", slog.String("repoURL", helmapp.Spec.Source.RepoURL), slog.Any("error", err))
				return fmt.Errorf("failed to parse repo url: %w", err)
			}

			eg.Go(func() error {
				hc, err := lib.NewHelmClient()
				if err != nil {
					slog.Error("failed to create helm client", slog.Any("error", err))
					return fmt.Errorf("failed to create helm client: %w", err)
				}

				gen, err := hc.HelmTemplate(
					context.Background(),
					helmapp.Spec.Source.Helm.ReleaseName,
					helmapp.Spec.Destination.Namespace,
					*repoURL,
					helmapp.Spec.Source.Chart,
					helmapp.Spec.Source.TargetRevision,
					helmapp.Spec.Source.Helm.Values,
					helmapp.Spec.Source.Helm.ValuesObject,
				)
				if err != nil {
					slog.Error("failed to generate helm template", slog.Any("error", err),
						slog.String("release_name", helmapp.Spec.Source.Helm.ReleaseName),
						slog.String("namespace", helmapp.Spec.Destination.Namespace),
						slog.String("repo_url", helmapp.Spec.Source.RepoURL),
						slog.String("chart", helmapp.Spec.Source.Chart),
						slog.String("target_revision", helmapp.Spec.Source.TargetRevision),
					)
					return fmt.Errorf("failed to generate helm template : %w", err)
				}

				file, err := os.Create(filepath.Join(b.outFileDir, helmapp.Metadata.Name+".yaml"))
				if err != nil {
					slog.Error("failed to create file", slog.String("path", path), slog.Any("error", err))
					return fmt.Errorf("failed to create file: %w", err)
				}
				defer file.Close()

				if _, err := io.Copy(file, gen); err != nil {
					slog.Error("failed to copy file", slog.String("path", path), slog.Any("error", err))
					return fmt.Errorf("failed to copy file: %w", err)
				}
				return nil
			})
		}
		return nil
	}); err != nil {
		slog.Error("failed to walk app directory", slog.String("appSnapshotDir", b.appSnapshotDir), slog.Any("error", err))
		return subcommands.ExitFailure
	}

	if err := eg.Wait(); err != nil {
		slog.Error("failed to wait errgroup", slog.Any("error", err))
		return subcommands.ExitFailure
	}

	return subcommands.ExitSuccess
}
