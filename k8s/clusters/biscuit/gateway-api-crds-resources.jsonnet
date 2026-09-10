local cluster = import 'cluster.json5';
local resourcePayload = |||
  apiVersion: v1
  kind: ServiceAccount
  metadata:
    name: gateway-api-crds
    namespace: kube-system
  ---
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRole
  metadata:
    name: gateway-api-crds
  rules:
  - apiGroups:
    - apiextensions.k8s.io
    resources:
    - customresourcedefinitions
    verbs:
    - create
    - get
    - list
    - patch
    - update
    - watch
  - apiGroups:
    - admissionregistration.k8s.io
    resources:
    - validatingadmissionpolicies
    - validatingadmissionpolicybindings
    verbs:
    - create
    - get
    - list
    - patch
    - update
    - watch
  ---
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRoleBinding
  metadata:
    name: gateway-api-crds
  roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: gateway-api-crds
  subjects:
  - kind: ServiceAccount
    name: gateway-api-crds
    namespace: kube-system
  ---
  apiVersion: batch/v1
  kind: Job
  metadata:
    name: gateway-api-crds
    namespace: kube-system
  spec:
    activeDeadlineSeconds: 600
    backoffLimit: 6
    template:
      metadata:
        labels:
          app.kubernetes.io/name: gateway-api-crds
      spec:
        restartPolicy: OnFailure
        serviceAccountName: gateway-api-crds
        containers:
        - name: kubectl
          image: registry.k8s.io/kubectl:v1.36.4
          command:
          - kubectl
          - apply
          - --server-side
          - --field-manager=argocd-controller
          - -f
          - https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
|||;
{
  apiVersion: 'v1',
  kind: 'Secret',
  metadata: {
    name: 'gateway-api-crds-resources',
    namespace: cluster.namespace,
    annotations: {
      'argocd.argoproj.io/sync-wave': '18',
    },
  },
  type: 'addons.cluster.x-k8s.io/resource-set',
  stringData: {
    'resources.yaml': resourcePayload,
  },
}
