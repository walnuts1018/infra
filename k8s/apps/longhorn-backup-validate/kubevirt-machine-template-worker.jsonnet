{
  apiVersion: 'infrastructure.cluster.x-k8s.io/v1alpha1',
  kind: 'KubevirtMachineTemplate',
  metadata: {
    name: (import 'app.json5').name + '-worker',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    template: {
      spec: {
        virtualMachineBootstrapCheck: {
          checkStrategy: 'none',
        },
        virtualMachineTemplate: {
          metadata: {
            namespace: (import 'app.json5').namespace,
            labels: {
              app: (import 'app.json5').name + '-worker',
            },
          },
          spec: {
            instancetype: {
              kind: 'VirtualMachineClusterInstancetype',
              name: 'o1.large',
            },
            preference: {
              kind: 'VirtualMachineClusterPreference',
              name: 'ubuntu',
            },
            dataVolumeTemplates: [
              {
                metadata: {
                  name: 'boot-volume',
                },
                spec: {
                  pvc: {
                    accessModes: ['ReadWriteOnce'],
                    resources: {
                      requests: {
                        storage: '64Gi',
                      },
                    },
                    storageClassName: 'local-path',
                  },
                  source: {
                    pvc: {
                      name: (import 'pvc-base.jsonnet').metadata.name,
                      namespace: (import 'pvc-base.jsonnet').metadata.namespace,
                    },
                  },
                },
              },
            ],
            runStrategy: 'Always',
            template: {
              metadata: {
                labels: {
                  app: (import 'app.json5').name + '-worker',
                },
              },
              spec: {
                domain: {
                  devices: {
                    networkInterfaceMultiqueue: true,
                    disks: [
                      {
                        disk: {
                          bus: 'virtio',
                        },
                        name: 'dv-volume',
                      },
                    ],
                  },
                },
                affinity: {
                  nodeAffinity: {
                    preferredDuringSchedulingIgnoredDuringExecution: [
                      {
                        weight: 100,
                        preference: {
                          matchExpressions: [
                            {
                              key: 'kubernetes.io/hostname',
                              operator: 'In',
                              values: [
                                'cake',
                              ],
                            },
                          ],
                        },
                      },
                    ],
                  },
                },
                evictionStrategy: 'External',
                volumes: [
                  {
                    dataVolume: {
                      name: 'boot-volume',
                    },
                    name: 'dv-volume',
                  },
                ],
              },
            },
          },
        },
      },
    },
  },
}
