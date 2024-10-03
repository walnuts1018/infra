package blog

import (
	"path/filepath"

	"github.com/walnuts1018/infra/k8s/chart/app"
	"github.com/walnuts1018/infra/k8s/chart/deployment"
	"github.com/walnuts1018/infra/k8s/chart/service"
)

const (
	appname        = "blog"
	deploymentName = appname
	serviceName    = appname
	namespace      = "default"
)

func New() {
	app := app.NewApp(filepath.Join(app.AppDir, appname))

	deployment.NewDeploymentChart(app, deploymentName, namespace, &deploy)
	service.NewServiceChart(app, serviceName, namespace, &svc)
	app.Synth()
}
