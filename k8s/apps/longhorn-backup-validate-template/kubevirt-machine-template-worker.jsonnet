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
              name: 'u1.large',
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
                        storage: '16Gi',
                      },
                    },
                    storageClassName: 'longhorn-local',
                    dataSource: {
                      apiGroup: '',
                      kind: 'PersistentVolumeClaim',
                      name: (import 'pvc-base.jsonnet').metadata.name,
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
                      {
                        disk: {
                          bus: 'virtio',
                        },
                        name: 'cloudinitdisk',
                      },
                      {
                        disk: {
                          bus: 'virtio',
                        },
                        name: 'longhorn-volume',
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
                  {
                    name: 'cloudinitdisk',
                    cloudInitNoCloud: {
                      userData: '#cloud-config\n' + std.manifestYamlDoc({
                        bootcmd: [
                          'sudo mkdir -p /var/lib/longhorn/',
                          'sudo mount /dev/vdb /var/lib/longhorn/',
                        ],
                      }) + '\n',
                    },
                  },
                  {
                    emptyDisk: {
                      capacity: '128Gi',
                    },
                    name: 'longhorn-volume',
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
