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
      secretKey: 'backup_access_key',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'seaweedfs_biscuit_backup_access_key',
      },
    },
    {
      secretKey: 'backup_secret_key',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'seaweedfs_biscuit_backup_secret_key',
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
        "name": "kurumi-cloudnative-pg-backup",
        "credentials": [
          {
            "accessKey": "{{ .backup_access_key }}",
            "secretKey": "{{ .backup_secret_key }}"
          }
        ],
        "actions": ["Read", "Write", "List", "Tagging"],
        "resources": ["buckets/cloudnative-pg-backup"]
      }
        ]
      }
    |||,
  },
}
