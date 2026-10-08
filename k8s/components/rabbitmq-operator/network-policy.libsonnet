function(app, component)
  {
    apiVersion: 'cilium.io/v2',
    kind: 'CiliumNetworkPolicy',
    metadata: {
      name: app.name + '-network-policy',
      namespace: app.namespace,
    },
    spec: {
      endpointSelector: {
        matchLabels: {
          'k8s:app.kubernetes.io/component': component,
          'k8s:app.kubernetes.io/name': app.name,
        },
      },
      ingress: [{
        toPorts: [{ ports: [{ port: '9443', protocol: 'TCP' }] }],
      }],
      egress: [
        {
          toEndpoints: [{
            matchLabels: {
              'k8s:io.kubernetes.pod.namespace': 'kube-system',
              'k8s:k8s-app': 'kube-dns',
            },
          }],
          toPorts: [{ ports: [
            { port: '53', protocol: 'UDP' },
            { port: '53', protocol: 'TCP' },
          ] }],
        },
        {
          toEntities: ['kube-apiserver'],
          toPorts: [{ ports: [
            { port: '443', protocol: 'TCP' },
            { port: '6443', protocol: 'TCP' },
          ] }],
        },
        {
          toEndpoints: [{
            matchLabels: {
              'k8s:app.kubernetes.io/component': 'rabbitmq',
              'k8s:app.kubernetes.io/name': 'default',
              'k8s:io.kubernetes.pod.namespace': 'rabbitmq',
            },
          }],
          toPorts: [{ ports: [{ port: '15672', protocol: 'TCP' }] }],
        },
      ],
    },
  }
