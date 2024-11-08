package lib

import (
	"bufio"
	"fmt"
	"io"
	"iter"
	"strings"

	"github.com/go-playground/validator/v10"
	"sigs.k8s.io/yaml"
)

type HelmApplication struct {
	Metadata struct {
		Name string `yaml:"name" validate:"required"`
	} `yaml:"metadata"`
	Spec struct {
		Destination struct {
			Namespace string `yaml:"namespace"`
		} `yaml:"destination"`
		Source struct {
			Chart string `yaml:"chart" validate:"required"`
			Helm  struct {
				ReleaseName  string                 `yaml:"releaseName" validate:"required"`
				Values       string                 `yaml:"values"`
				ValuesObject map[string]interface{} `yaml:"valuesObject"`
			} `yaml:"helm"`
			RepoURL        string `yaml:"repoURL" validate:"required"`
			TargetRevision string `yaml:"targetRevision" validate:"required"`
		} `yaml:"source"`
	} `yaml:"spec"`
}

var validate = validator.New()

var ErrNotHelmApplication = fmt.Errorf("not a helm application")

func ParseHelmApplications(reader io.Reader) (iter.Seq2[HelmApplication, error], error) {
	scanner := bufio.NewScanner(reader)
	scanner.Buffer(make([]byte, 4096, bufio.MaxScanTokenSize*10), bufio.MaxScanTokenSize*10)

	return func(yield func(HelmApplication, error) bool) {
		lines := []string{}
		for scanner.Scan() {
			line := scanner.Text()
			if isSeparator(line) {
				var app HelmApplication
				if err := yaml.Unmarshal([]byte(strings.Join(lines, "\n")), &app); err != nil {
					if !yield(HelmApplication{}, fmt.Errorf("failed to unmarshal yaml: %w", err)) {
						return
					}
				}
				lines = []string{}

				if err := scanner.Err(); err != nil {
					if !yield(HelmApplication{}, fmt.Errorf("failed to read line: %w", err)) {
						return
					}
				}

				if err := validate.Struct(app); err != nil {
					if !yield(HelmApplication{}, ErrNotHelmApplication) {
						return
					}
				} else {
					if !yield(app, nil) {
						return
					}
				}
			}
			lines = append(lines, line)
		}

		if err := scanner.Err(); err != nil {
			if !yield(HelmApplication{}, fmt.Errorf("failed to read line: %w", err)) {
				return
			}
		}

		if len(lines) > 0 {
			var app HelmApplication
			if err := yaml.Unmarshal([]byte(strings.Join(lines, "\n")), &app); err != nil {
				if !yield(HelmApplication{}, fmt.Errorf("failed to unmarshal yaml: %w", err)) {
					return
				}
			}

			if err := validate.Struct(app); err != nil {
				if !yield(HelmApplication{}, ErrNotHelmApplication) {
					return
				}
			} else {
				if !yield(app, nil) {
					return
				}
			}
		}
	}, nil
}

func isSeparator(s string) bool {
	return strings.HasPrefix(s, "---")
}
