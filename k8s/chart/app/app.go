package app

import (
	"path/filepath"

	"github.com/aws/jsii-runtime-go"
	"github.com/cdk8s-team/cdk8s-core-go/cdk8s/v2"
)

const (
	GenerateDir = "_generated"
	AppDir      = "apps"
)

func NewApp(path string) cdk8s.App {
	app := cdk8s.NewApp(&cdk8s.AppProps{
		Outdir:              jsii.String(filepath.Join(GenerateDir, path)),
		OutputFileExtension: jsii.String(".yaml"),
	})
	return app
}
