package blog

import (
	"path/filepath"

	"github.com/walnuts1018/infra/k8s/chart/app"
	"github.com/walnuts1018/infra/k8s/chart/deployment"
	"github.com/walnuts1018/infra/k8s/chart/service"
	"github.com/walnuts1018/infra/k8s/namespace"
)

const (
	appname        = "blog"
	deploymentName = appname
	serviceName    = appname
	ns             = namespace.Default
)

func New() {
	app := app.NewApp(filepath.Join(app.AppDir, appname))

	deployment.NewDeploymentChart(app, deploymentName, ns, &deploy)
	service.NewServiceChart(app, serviceName, ns, &svc)
	app.Synth()
}
