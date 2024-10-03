package deployment

import (
	"maps"

	"github.com/aws/constructs-go/constructs/v10"
	"github.com/cdk8s-team/cdk8s-core-go/cdk8s/v2"
	"github.com/walnuts1018/infra/k8s/imports/k8s"
	"github.com/walnuts1018/infra/k8s/namespace"
	"k8s.io/utils/ptr"
)

const id = "deployment"

func NewDeploymentChart(scope constructs.Construct, name string, namespace namespace.Namespace, deploy *k8s.KubeDeploymentProps) cdk8s.Chart {
	chart := cdk8s.NewChart(scope, ptr.To(id), &cdk8s.ChartProps{
		DisableResourceNameHashes: ptr.To(true),
		Namespace:                 ptr.To(string(namespace)),
	})

	if deploy.Metadata == nil {
		deploy.Metadata = &k8s.ObjectMeta{}
	}

	deploy.Metadata.Name = ptr.To(name)
	deploy.Metadata.Namespace = ptr.To(string(namespace))

	addLabels(deploy, name)
	addContainerSecurityContext(deploy)

	k8s.NewKubeDeployment(chart, ptr.To(name), deploy)
	return chart
}

func addLabels(deploy *k8s.KubeDeploymentProps, name string) {
	labels := map[string]*string{
		"app":                    ptr.To(name),
		"app.kubernetes.io/name": ptr.To(name),
	}
	if deploy.Metadata == nil {
		deploy.Metadata = &k8s.ObjectMeta{}
	}
	if deploy.Metadata.Labels == nil {
		deploy.Metadata.Labels = &map[string]*string{}
	}
	maps.Insert(*deploy.Metadata.Labels, maps.All(labels))

	if deploy.Spec.Template.Metadata == nil {
		deploy.Spec.Template.Metadata = &k8s.ObjectMeta{}
	}
	if deploy.Spec.Template.Metadata.Labels == nil {
		deploy.Spec.Template.Metadata.Labels = &map[string]*string{}
	}
	maps.Insert(*deploy.Spec.Template.Metadata.Labels, maps.All(labels))

	if deploy.Spec.Selector == nil {
		deploy.Spec.Selector = &k8s.LabelSelector{}
	}

	if deploy.Spec.Selector.MatchLabels == nil {
		deploy.Spec.Selector.MatchLabels = &map[string]*string{}
	}
	maps.Insert(*deploy.Spec.Selector.MatchLabels, maps.All(labels))
}

func addContainerSecurityContext(deploy *k8s.KubeDeploymentProps) {
	for _, container := range *deploy.Spec.Template.Spec.Containers {
		if container.SecurityContext != nil {
			continue
		}
		container.SecurityContext = &k8s.SecurityContext{
			ReadOnlyRootFilesystem: ptr.To(true),
			SeccompProfile: &k8s.SeccompProfile{
				Type: ptr.To("RuntimeDefault"),
			},
		}
	}
}
