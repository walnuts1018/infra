package lib

import (
	"context"
	"io"
	"net/url"
	"testing"

	"sigs.k8s.io/yaml"
)

func TestHelmClient_HelmTemplate(t *testing.T) {
	type args struct {
		ctx          context.Context
		name         string
		namespace    string
		repoURL      url.URL
		chartName    string
		chartVersion string
		valuesString string
		valuesObject map[string]interface{}
	}
	tests := []struct {
		name    string
		args    args
		want    string
		wantErr bool
	}{
		{
			name: "test",
			args: args{
				ctx:       context.Background(),
				name:      "ingress-nginx-release",
				namespace: "ingress-nginx",
				repoURL: url.URL{
					Scheme: "https",
					Host:   "kubernetes.github.io",
					Path:   "/ingress-nginx",
				},
				chartName:    "ingress-nginx",
				chartVersion: "4.11.3",
				valuesString: `
controller:
  replicaCount: 2
`,
			},
			wantErr: false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			c, err := NewHelmClient()
			if err != nil {
				t.Errorf("HelmClient.HelmTemplate() error = %v", err)
				return
			}

			got, err := c.HelmTemplate(tt.args.ctx, tt.args.name, tt.args.namespace, tt.args.repoURL, tt.args.chartName, tt.args.chartVersion, tt.args.valuesString, tt.args.valuesObject)
			if (err != nil) != tt.wantErr {
				t.Errorf("HelmClient.HelmTemplate() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			gotStr, err := io.ReadAll(got)
			if err != nil {
				t.Errorf("HelmClient.HelmTemplate() error = %v", err)
				return
			}

			if err := yaml.Unmarshal([]byte(gotStr), map[string]any{}); err != nil {
				t.Errorf("HelmClient.HelmTemplate() error = %v", err)
				return
			}
		})
	}
}
