package namespace

type Namespace string

const (
	Default                     Namespace = "default"
	IngressNginx                Namespace = "ingress-nginx"
	LonghornSystem              Namespace = "longhorn-system"
	NetworkExporter             Namespace = "network-exporter"
	CodeServer                  Namespace = "code-server"
	Misskey                     Namespace = "misskey"
	Monitoring                  Namespace = "monitoring"
	CertManager                 Namespace = "cert-manager"
	Databases                   Namespace = "databases"
	KrakendSystem               Namespace = "krakend-system"
	ExternalSecrets             Namespace = "external-secrets"
	Minio                       Namespace = "minio"
	Kubevirt                    Namespace = "kubevirt"
	AcHacking2024               Namespace = "ac-hacking-2024"
	Photoprism                  Namespace = "photoprism"
	OpentelemetryOperatorSystem Namespace = "opentelemetry-operator-system"
	OpentelemetryCollector      Namespace = "opentelemetry-collector"
	Komga                       Namespace = "komga"
	CiliumSystem                Namespace = "cilium-system"
	Onepassword                 Namespace = "onepassword"
	PolicyController            Namespace = "policy-controller"
	Flagger                     Namespace = "flagger"
	Signoz                      Namespace = "signoz"
)
