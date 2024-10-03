package service

import (
	"maps"

	"github.com/aws/constructs-go/constructs/v10"
	"github.com/cdk8s-team/cdk8s-core-go/cdk8s/v2"
	"github.com/walnuts1018/infra/k8s/imports/k8s"
	"github.com/walnuts1018/infra/k8s/namespace"
	"k8s.io/utils/ptr"
)

const id = "service"

func NewServiceChart(scope constructs.Construct, name string, namespace namespace.Namespace, service *k8s.KubeServiceProps) cdk8s.Chart {
	chart := cdk8s.NewChart(scope, ptr.To(id), &cdk8s.ChartProps{
		DisableResourceNameHashes: ptr.To(true),
		Namespace:                 ptr.To(string(namespace)),
	})

	if service.Metadata == nil {
		service.Metadata = &k8s.ObjectMeta{}
	}

	insertLabels(service, name)

	k8s.NewKubeService(chart, ptr.To(name), service)
	return chart
}

func insertLabels(service *k8s.KubeServiceProps, name string) {
	labels := map[string]*string{
		"app":                    ptr.To(name),
		"app.kubernetes.io/name": ptr.To(name),
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
