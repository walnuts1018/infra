package service

import (
	"github.com/aws/constructs-go/constructs/v10"
	"github.com/aws/jsii-runtime-go"
	"github.com/cdk8s-team/cdk8s-core-go/cdk8s/v2"
	"github.com/walnuts1018/infra/k8s/imports/k8s"
)

const id = "namespace"

func NewNamespaceChart(scope constructs.Construct, name string, namepsace *k8s.KubeNamespaceProps) cdk8s.Chart {
	chart := cdk8s.NewChart(scope, jsii.String(id), &cdk8s.ChartProps{
		DisableResourceNameHashes: jsii.Bool(true),
	})

	k8s.NewKubeNamespace(chart, jsii.String(name), namepsace)
	return chart
}
