package service

import (
	"maps"

	"github.com/aws/constructs-go/constructs/v10"
	"github.com/aws/jsii-runtime-go"
	"github.com/cdk8s-team/cdk8s-core-go/cdk8s/v2"
	"github.com/walnuts1018/infra/k8s/imports/k8s"
)

const id = "service"

func NewServiceChart(scope constructs.Construct, name, namespace string, service *k8s.KubeServiceProps) cdk8s.Chart {
	chart := cdk8s.NewChart(scope, jsii.String(id), &cdk8s.ChartProps{
		DisableResourceNameHashes: jsii.Bool(true),
		Namespace:                 jsii.String(namespace),
	})

	if service.Metadata == nil {
		service.Metadata = &k8s.ObjectMeta{}
	}

	insertLabels(service, name)

	k8s.NewKubeService(chart, jsii.String(name), service)
	return chart
}

func insertLabels(service *k8s.KubeServiceProps, name string) {
	labels := map[string]*string{
		"app":                    jsii.String(name),
		"app.kubernetes.io/name": jsii.String(name),
	}
	if service.Metadata == nil {
		service.Metadata = &k8s.ObjectMeta{}
	}
	if service.Metadata.Labels == nil {
		service.Metadata.Labels = &map[string]*string{}
	}
	maps.Insert(*service.Metadata.Labels, maps.All(labels))

	if service.Spec.Selector == nil {
		service.Spec.Selector = &map[string]*string{}
	}

	maps.Insert(*service.Spec.Selector, maps.All(labels))
}
