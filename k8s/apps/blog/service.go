package blog

import (
	"github.com/aws/jsii-runtime-go"
	"github.com/walnuts1018/infra/k8s/imports/k8s"
	"k8s.io/utils/ptr"
)

var svc = k8s.KubeServiceProps{
	Spec: &k8s.ServiceSpec{
		Ports: &[]*k8s.ServicePort{
			{
				Protocol:   ptr.To("TCP"),
				Port:       jsii.Number(8080),
				TargetPort: k8s.IntOrString_FromNumber(jsii.Number(8080)),
			},
		},
		Type: ptr.To("ClusterIP"),
	},
}
