package props

import (
	"github.com/walnuts1018/infra/k8s/imports/k8s"
	"k8s.io/utils/ptr"
)

type ResourceRequirementsOption struct {
	Request map[string]string
	Limit   map[string]string
}

func NewResourceRequirements(
	cpuRequest,
	cpuLimit,
	memoryRequest,
	memoryLimit string,
	opt ...ResourceRequirementsOption,
) *k8s.ResourceRequirements {
	limits := make(map[string]k8s.Quantity)
	requests := make(map[string]k8s.Quantity)

	if cpuLimit != "" {
		limits["cpu"] = k8s.Quantity_FromString(ptr.To(cpuLimit))
	}
	if cpuRequest != "" {
		requests["cpu"] = k8s.Quantity_FromString(ptr.To(cpuRequest))
	}
	if memoryLimit != "" {
		limits["memory"] = k8s.Quantity_FromString(ptr.To(memoryLimit))
	}
	if memoryRequest != "" {
		requests["memory"] = k8s.Quantity_FromString(ptr.To(memoryRequest))
	}

	if len(opt) > 0 {
		for k, v := range opt[0].Limit {
			limits[k] = k8s.Quantity_FromString(ptr.To(v))
		}

		for k, v := range opt[0].Request {
			requests[k] = k8s.Quantity_FromString(ptr.To(v))
		}
	}

	return &k8s.ResourceRequirements{
		Limits:   &limits,
		Requests: &requests,
	}
}
