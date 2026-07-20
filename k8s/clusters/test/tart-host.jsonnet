{
  apiVersion: 'infrastructure.cluster.x-k8s.io/v1beta1',
  kind: 'TartHost',
  metadata: {
    name: 'rusk',
    namespace: (import 'cluster.json5').namespace,
    labels: {
      'tart.walnuts.dev/role': 'control-plane',
    },
  },
  spec: {
    identifiers: {
      systemUUID: '34373737-3632-504A-5436-30374452504E',
      bootMACAddress: '94:57:a5:c4:98:4b',
    },
    architecture: 'amd64',
    firmware: 'UEFI',
    platformProfile: 'amd64-uefi-ab-ubuntu-26.04-kubeadm/v1',
    rootDeviceHints: {
      deviceName: '/dev/disk/by-id/wwn-0x600508b1001c135158ec5ba7ececcb97',
      wwn: '0x600508b1001c135158ec5ba7ececcb97',
      minSizeBytes: 68719476736,
    },
    management: {
      powerDriver: 'redfish',
      bootDriver: 'ipxe',
      credentialsSecretRef: {
        name: 'rusk-bmc',
      },
      redfish: {
        endpoint: 'https://192.168.4.101',
        caBundleSecretRef: {
          name: 'rusk-bmc-ca',
        },
      },
    },
  },
}
