package deployment

import (
	"reflect"
	"testing"

	"github.com/aws/jsii-runtime-go"
	"github.com/cdk8s-team/cdk8s-core-go/cdk8s/v2"
	"github.com/walnuts1018/infra/k8s/chart/app"
	"github.com/walnuts1018/infra/k8s/imports/k8s"
	"github.com/walnuts1018/infra/k8s/namespace"
)

func TestNewDeploymentChart(t *testing.T) {
	type args struct {
		app       cdk8s.App
		name      string
		namespace namespace.Namespace
		deploy    *k8s.KubeDeploymentProps
	}
	tests := []struct {
		name     string
		args     args
		wantYaml string
	}{
		{
			name: "normal",
			args: args{
				app:       app.NewApp("app/test"),
				name:      "k8s_name",
				namespace: namespace.Default,
				deploy: &k8s.KubeDeploymentProps{
					Metadata: &k8s.ObjectMeta{
						Name:      jsii.String("k8s_name"),
						Namespace: jsii.String("default"),
					},
					Spec: &k8s.DeploymentSpec{
						Replicas: jsii.Number(3),
						Template: &k8s.PodTemplateSpec{
							Spec: &k8s.PodSpec{
								Containers: &[]*k8s.Container{{
									Name:  jsii.String("app-container"),
									Image: jsii.String("nginx:1.19.10"),
									Ports: &[]*k8s.ContainerPort{{
										ContainerPort: jsii.Number(80),
									}},
								}},
							},
						},
					},
				},
			},
			wantYaml: `apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: k8s_name
    app.kubernetes.io/name: k8s_name
  name: k8s_name
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: k8s_name
      app.kubernetes.io/name: k8s_name
  template:
    metadata:
      labels:
        app: k8s_name
        app.kubernetes.io/name: k8s_name
    spec:
      containers:
        - image: nginx:1.19.10
          name: app-container
          ports:
            - containerPort: 80
          securityContext:
            readOnlyRootFilesystem: true
            seccompProfile:
              type: RuntimeDefault
`,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			NewDeploymentChart(tt.args.app, tt.args.name, tt.args.namespace, tt.args.deploy)
			gotyaml := tt.args.app.SynthYaml()
			if !reflect.DeepEqual(*gotyaml, tt.wantYaml) {
				t.Errorf("NewDeploymentChart() = %v, want %v", *gotyaml, tt.wantYaml)
			}
		})
	}
}
