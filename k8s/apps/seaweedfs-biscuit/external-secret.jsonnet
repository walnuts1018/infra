local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';

externalSecret {
  name: app.name + '-s3-config',
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'access_key',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'seaweedfs_biscuit_access_key',
      },
    },
    {
      secretKey: 'secret_key',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'seaweedfs_biscuit_secret_key',
      },
    },
  ],
  template_data: {
    'seaweedfs_s3_config.json': |||
      {
        "identities": [
          {
            "name": "cloudnative-pg-backup",
            "credentials": [
              {
                "accessKey": "{{ .access_key }}",
                "secretKey": "{{ .secret_key }}"
              }
            ],
            "actions": ["Read", "Write", "List", "Tagging"]
          }
        ]
      }
    |||,
  },
}
