local app = import 'app.json5';
local clusterName = app.name;
local namespace = app.namespace;
local issuerRef = {
  name: 'local',
  kind: 'ClusterIssuer',
  group: 'cert-manager.io',
};
local certificate(name, commonName, usages, dnsNames=[]) = {
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: name,
    namespace: namespace,
  },
  spec: {
    secretName: name,
    duration: '8760h',
    renewBefore: '360h',
    commonName: commonName,
    usages: usages,
    [if std.length(dnsNames) > 0 then 'dnsNames']: dnsNames,
    issuerRef: issuerRef,
  },
};
local serviceNames(component) = [
  clusterName + '-' + component,
  clusterName + '-' + component + '.' + namespace,
  clusterName + '-' + component + '.' + namespace + '.svc',
  clusterName + '-' + component + '.' + namespace + '.svc.cluster.local',
  clusterName + '-' + component + '-peer',
  clusterName + '-' + component + '-peer.' + namespace,
  clusterName + '-' + component + '-peer.' + namespace + '.svc',
  clusterName + '-' + component + '-peer.' + namespace + '.svc.cluster.local',
  '*.' + clusterName + '-' + component + '-peer',
  '*.' + clusterName + '-' + component + '-peer.' + namespace,
  '*.' + clusterName + '-' + component + '-peer.' + namespace + '.svc',
  '*.' + clusterName + '-' + component + '-peer.' + namespace + '.svc.cluster.local',
];
[
  certificate(clusterName + '-pd-cluster-secret', 'TiDB', ['server auth', 'client auth'], serviceNames('pd')),
  certificate(clusterName + '-tikv-cluster-secret', 'TiDB', ['server auth', 'client auth'], serviceNames('tikv')),
  certificate(clusterName + '-cluster-client-secret', 'TiDB', ['client auth']),
]
