package lib

import (
	_ "embed"
	"testing"

	"github.com/sters/yaml-diff/yamldiff"
)

var (
	//go:embed testfiles/deployment.yaml
	deploymentYAML string

	//go:embed testfiles/ingress.yaml
	ingressYAML string

	//go:embed testfiles/pvc.yaml
	pvcYAML string

	//go:embed testfiles/service.yaml
	serviceYAML string
)

func TestBuildYAML(t *testing.T) {
	type args struct {
		filepath string
	}
	tests := []struct {
		name    string
		args    args
		want    string
		wantErr bool
	}{
		{
			name: "deployment",
			args: args{
				filepath: "./testfiles/deployment.jsonnet",
			},
			want:    deploymentYAML,
			wantErr: false,
		},
		{
			name: "ingress",
			args: args{
				filepath: "./testfiles/ingress.jsonnet",
			},
			want:    ingressYAML,
			wantErr: false,
		},
		{
			name: "pvc",
			args: args{
				filepath: "./testfiles/pvc.jsonnet",
			},
			want:    pvcYAML,
			wantErr: false,
		}, {
			name: "service",
			args: args{
				filepath: "./testfiles/service.jsonnet",
			},
			want:    serviceYAML,
			wantErr: false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := BuildYAML(tt.args.filepath)
			if (err != nil) != tt.wantErr {
				t.Errorf("BuildYAML() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			equal, diff, err := yamlEqual(got, tt.want)
			if err != nil {
				t.Errorf("yamlEqual() error = %v", err)
				return
			}

			if !equal {
				t.Errorf("Diff: %v", diff)
			}
		})
	}
}

func yamlEqual(a, b string) (bool, []string, error) {
	yamlA, err := yamldiff.Load(a)
	if err != nil {
		return false, []string{}, err
	}

	yamlB, err := yamldiff.Load(b)
	if err != nil {
		return false, []string{}, err
	}

	diff := yamldiff.Do(yamlA, yamlB)
	for _, d := range diff {
		if d.Status() != yamldiff.DiffStatusSame {
			return false, []string{d.Dump()}, nil
		}
	}

	return true, []string{}, nil
}
