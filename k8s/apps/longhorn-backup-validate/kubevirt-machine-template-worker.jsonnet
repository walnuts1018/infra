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
                    volumeMode: 'Block',
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
                      name: 'talos-1-8-2-openstack.img',
                    },
                  },
                },
              },
            ],
            runStrategy: 'Once',
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
