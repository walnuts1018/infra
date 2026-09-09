local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';

externalSecret {
  name: app.name + '-s3-config',
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'terraform_access_key',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'seaweedfs_biscuit_terraform_access_key',
      },
    },
    {
      secretKey: 'terraform_secret_key',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'seaweedfs_biscuit_terraform_secret_key',
      },
    },
    {
      secretKey: 'velero_access_key',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'seaweedfs_biscuit_velero_access_key',
      },
    },
    {
      secretKey: 'velero_secret_key',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'seaweedfs_biscuit_velero_secret_key',
      },
    },
    {
      secretKey: 'longhorn_access_key',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'seaweedfs_biscuit_longhorn_access_key',
      },
    },
    {
      secretKey: 'longhorn_secret_key',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'seaweedfs_biscuit_longhorn_secret_key',
      },
    },
    {
      secretKey: 'default_backup_access_key',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'seaweedfs_biscuit_default_backup_access_key',
      },
    },
    {
      secretKey: 'default_backup_secret_key',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'seaweedfs_biscuit_default_backup_secret_key',
      },
    },
  ],
  template_data: {
    'seaweedfs_s3_config.json': |||
      {
        "identities": [
          {
            "name": "terraform",
            "credentials": [
              {
                "accessKey": "{{ .terraform_access_key }}",
                "secretKey": "{{ .terraform_secret_key }}"
              }
            ],
            "actions": ["Admin", "Read", "Write", "List", "Tagging"]
          },
          {
            "name": "velero",
            "credentials": [
              {
                "accessKey": "{{ .velero_access_key }}",
                "secretKey": "{{ .velero_secret_key }}"
              }
            ],
            "actions": ["Read", "Write", "List", "Tagging"],
            "resources": ["buckets/velero-backup"]
          },
          {
            "name": "longhorn",
            "credentials": [
              {
                "accessKey": "{{ .longhorn_access_key }}",
                "secretKey": "{{ .longhorn_secret_key }}"
              }
            ],
            "actions": ["Read", "Write", "List", "Tagging"],
            "resources": ["buckets/longhorn-backup"]
          },
          {
            "name": "seaweedfs-default-backup",
            "credentials": [
              {
                "accessKey": "{{ .default_backup_access_key }}",
                "secretKey": "{{ .default_backup_secret_key }}"
              }
            ],
            "actions": ["Read", "Write", "List", "Tagging"],
            "resources": ["buckets/seaweedfs-default-backup"]
          }
        ]
      }
    |||,
  },
}
