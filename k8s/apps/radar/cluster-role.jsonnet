local zitadelKubernetesRbacApp = import '../zitadel-kubernetes-rbac/app.json5';
local app = import 'app.json5';


{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRole',
  metadata: {
    name: 'radar-informer',
  },
  rules: [
    {
      apiGroups: [''],
      resources: [
        'pods',
        'services',
        'configmaps',
        'events',
        'namespaces',
        'nodes',
        'persistentvolumes',
        'persistentvolumeclaims',
        'serviceaccounts',
        'endpoints',
        'limitranges',
        'resourcequotas',
      ],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['discovery.k8s.io'],
      resources: ['endpointslices'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['policy'],
      resources: ['poddisruptionbudgets'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['storage.k8s.io'],
      resources: ['storageclasses'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['storage.k8s.io'],
      resources: ['csidrivers', 'csistoragecapacities'],
      verbs: ['list'],
    },
    {
      apiGroups: ['flowcontrol.apiserver.k8s.io'],
      resources: ['flowschemas', 'prioritylevelconfigurations'],
      verbs: ['list'],
    },
    {
      apiGroups: ['apps'],
      resources: ['deployments', 'daemonsets', 'statefulsets', 'replicasets'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['networking.k8s.io'],
      resources: ['ingresses', 'ingressclasses', 'networkpolicies'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['scheduling.k8s.io'],
      resources: ['priorityclasses', 'workloads', 'podgroups', 'compositepodgroups'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['node.k8s.io'],
      resources: ['runtimeclasses'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['coordination.k8s.io'],
      resources: ['leases'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['certificates.k8s.io'],
      resources: ['podcertificaterequests', 'clustertrustbundles'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['batch'],
      resources: ['jobs', 'cronjobs'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['autoscaling'],
      resources: ['horizontalpodautoscalers'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['authorization.k8s.io'],
      resources: ['selfsubjectaccessreviews'],
      verbs: ['create'],
    },
    {
      apiGroups: [''],
      resources: ['pods/log'],
      verbs: ['get'],
    },
    {
      apiGroups: [''],
      resources: ['secrets'],
      resourceNames: ['hubble-relay-client-certs'],
      verbs: ['get'],
    },
    {
      apiGroups: ['metrics.k8s.io'],
      resources: ['pods', 'nodes'],
      verbs: ['get', 'list'],
    },
    {
      apiGroups: ['apiextensions.k8s.io'],
      resources: ['customresourcedefinitions'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['apiregistration.k8s.io'],
      resources: ['*'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['cert-manager.io', 'acme.cert-manager.io', 'trust.cert-manager.io'],
      resources: ['*'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['cilium.io'],
      resources: ['*'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['postgresql.cnpg.io', 'barmancloud.cnpg.io'],
      resources: ['*'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['descheduler.alpha.kubernetes.io'],
      resources: ['*'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['gateway.envoyproxy.io', 'gateway.networking.k8s.io'],
      resources: ['*'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['externaldns.k8s.io'],
      resources: ['*'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['external-secrets.io'],
      resources: ['*'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['snapshot.storage.k8s.io'],
      resources: ['*'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['keda.sh'],
      resources: ['*'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['nvidia.com'],
      resources: ['*'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['opentelemetry.io'],
      resources: ['*'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['monitoring.coreos.com'],
      resources: ['*'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['reloader.stakater.com'],
      resources: ['*'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['aquasecurity.github.io'],
      resources: ['*'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['velero.io'],
      resources: ['*'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: ['autoscaling.k8s.io'],
      resources: ['*'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: [
        'longhorn.io',
        'moco.cybozu.com',
        'rabbitmq.com',
        'scylla.scylladb.com',
        'pingcap.com',
        'databases.spotahome.com',
        'hazelcast.com',
      ],
      resources: ['*'],
      verbs: ['get', 'list', 'watch'],
    },
    {
      apiGroups: [''],
      resources: ['groups'],
      verbs: ['impersonate'],
      resourceNames: ['zitadel:' + zitadelKubernetesRbacApp.params.oidcIssuerAudience + ':radar-operator'],
    },
    {
      apiGroups: [''],
      resources: ['users'],
      verbs: ['impersonate'],
    },
    {
      apiGroups: ['authorization.k8s.io'],
      resources: ['subjectaccessreviews'],
      verbs: ['create'],
    },
  ],
}
