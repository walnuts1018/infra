package props

import (
	"github.com/walnuts1018/infra/k8s/imports/k8s"
	"k8s.io/utils/ptr"
)

func NewConfigMapVolume(volumeName, configmapName string, keyToPath map[string]string) *k8s.Volume {

	var items []*k8s.KeyToPath
	for key, path := range keyToPath {
		items = append(items, &k8s.KeyToPath{
			Key:  ptr.To(key),
			Path: ptr.To(path),
		})
	}
	return &k8s.Volume{
		Name: &volumeName,
		ConfigMap: &k8s.ConfigMapVolumeSource{
			Name:  &configmapName,
			Items: &items,
		},
	}
}

func NewEmptyDirVolume(volumeName string) *k8s.Volume {
	return &k8s.Volume{
		Name:     &volumeName,
		EmptyDir: &k8s.EmptyDirVolumeSource{},
	}
}
