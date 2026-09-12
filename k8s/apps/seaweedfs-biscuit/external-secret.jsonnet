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
      {{- $identities := list
        (dict "name" "terraform" "credentials" (list (dict "accessKey" .terraform_access_key "secretKey" .terraform_secret_key)) "actions" (list "Admin" "Read" "Write" "List" "Tagging"))
        (dict "name" "velero" "credentials" (list (dict "accessKey" .velero_access_key "secretKey" .velero_secret_key)) "actions" (list "Read:velero-backup" "Write:velero-backup" "List:velero-backup" "Tagging:velero-backup"))
        (dict "name" "longhorn" "credentials" (list (dict "accessKey" .longhorn_access_key "secretKey" .longhorn_secret_key)) "actions" (list "Read:longhorn-backup" "Write:longhorn-backup" "List:longhorn-backup" "Tagging:longhorn-backup"))
        (dict "name" "seaweedfs-default-backup" "credentials" (list (dict "accessKey" .default_backup_access_key "secretKey" .default_backup_secret_key)) "actions" (list "Read:seaweedfs-default-backup" "Write:seaweedfs-default-backup" "List:seaweedfs-default-backup" "Tagging:seaweedfs-default-backup"))
      -}}
      {{ dict "identities" $identities | toJson }}
    |||,
  },
}
