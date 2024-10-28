package main

import (
	"io"
	"reflect"
	"slices"
	"strings"
	"testing"

	_ "embed"

	"github.com/google/go-cmp/cmp"
)

var (
	//go:embed testfiles/deployment.yaml
	deploymentManifest string
	//go:embed testfiles/service.yaml
	serviceManifest string
)

func Test_getManifests(t *testing.T) {
	deploymentManifest := clean(deploymentManifest)
	serviceManifest := clean(serviceManifest)

	type args struct {
		reader io.Reader
	}
	tests := []struct {
		name string
		args args
		want []RawManifest
	}{
		{
			name: "1 Manifest",
			args: args{
				reader: strings.NewReader(deploymentManifest),
			},
			want: []RawManifest{
				RawManifest(deploymentManifest),
			},
		},
		{
			name: "top level ---",
			args: args{
				reader: strings.NewReader("---\n" + deploymentManifest),
			},
			want: []RawManifest{
				RawManifest(deploymentManifest),
			},
		},
		{
			name: "2 Manifests",
			args: args{
				reader: strings.NewReader(deploymentManifest + "---\n" + serviceManifest),
			},
			want: []RawManifest{
				RawManifest(deploymentManifest),
				RawManifest(serviceManifest),
			},
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := slices.Collect(getManifests(tt.args.reader)); !reflect.DeepEqual(got, tt.want) {
				for i, v := range tt.want {
					if !reflect.DeepEqual(got[i], v) {
						t.Errorf("[%d] getManifests() = %v, want %v", i, got[i], v)
						t.Errorf("Diff: %v", cmp.Diff(got[i], v))
					}
				}

			}
		})
	}
}
