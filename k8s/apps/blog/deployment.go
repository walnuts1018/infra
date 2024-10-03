package blog

import (
	"github.com/aws/jsii-runtime-go"
	"github.com/walnuts1018/infra/k8s/imports/k8s"
	"github.com/walnuts1018/infra/k8s/util/props"
	"k8s.io/utils/ptr"
)

var volumes = map[string]*k8s.Volume{
	"blog-conf": props.NewConfigMapVolume("blog-conf", "blog-conf", map[string]string{
		"nginx.conf":       "nginx.conf",
		"virtualhost.conf": "virtualhost/virtualhost.conf",
	}),
	"tmp":         props.NewEmptyDirVolume("tmp"),
	"log-nginx":   props.NewEmptyDirVolume("log-nginx"),
	"cache-nginx": props.NewEmptyDirVolume("cache-nginx"),
	"var-run":     props.NewEmptyDirVolume("var-run"),
}

var deploy = k8s.KubeDeploymentProps{
	Spec: &k8s.DeploymentSpec{
		Replicas: jsii.Number(1),
		Template: &k8s.PodTemplateSpec{
			Spec: &k8s.PodSpec{
				Containers: &[]*k8s.Container{
					{
						Name:  ptr.To("blog"),
						Image: ptr.To("nginx:1.27.1"),
						Ports: &[]*k8s.ContainerPort{
							{
								ContainerPort: jsii.Number(8080),
							},
						},
						SecurityContext: &k8s.SecurityContext{
							ReadOnlyRootFilesystem: ptr.To(true),
							SeccompProfile: &k8s.SeccompProfile{
								Type: ptr.To("RuntimeDefault"),
							},
						},
						VolumeMounts: &[]*k8s.VolumeMount{
							{
								Name:      volumes["blog-conf"].Name,
								MountPath: ptr.To("/etc/nginx"),
								ReadOnly:  ptr.To(true),
							},
							{
								MountPath: ptr.To("/tmp"),
								Name:      volumes["tmp"].Name,
							},
							{
								MountPath: ptr.To("/var/tmp"),
								Name:      volumes["tmp"].Name,
							},
							{
								MountPath: ptr.To("/var/log/nginx"),
								Name:      volumes["log-nginx"].Name,
							},
							{
								MountPath: ptr.To("/var/cache/nginx"),
								Name:      volumes["cache-nginx"].Name,
							},
							{
								MountPath: ptr.To("/var/run"),
								Name:      volumes["var-run"].Name,
							},
						},
						Resources: props.NewResourceRequirements("", "", "50Mi", "100Mi"),
					},
				},
				Volumes: props.ToVolumeSlice(volumes),
			},
		},
	},
}
