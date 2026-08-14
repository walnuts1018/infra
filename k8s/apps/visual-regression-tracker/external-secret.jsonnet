(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'jwt_secret',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'visual-regression-tracker-jwt-secret',
      },
    },
    {
      secretKey: 'postgres_password',
      remoteRef: {
        key: 'postgres_passwords',
        property: 'visual_regression_tracker',
      },
    },
    {
      secretKey: 'seaweedfs_secret_key',
      remoteRef: {
        key: 'seaweedfs',
        property: 'visual_regression_tracker_secretkey',
      },
    },
    {
      secretKey: 'admin_password',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'visual-regression-tracker-admin-password',
      },
    },
    {
      secretKey: 'admin_api_key',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'visual-regression-tracker-admin-api-key',
      },
    },
  ],
  template_data: {
    jwt_secret: '{{ .jwt_secret }}',
    DATABASE_URL: 'postgresql://visual_regression_tracker:{{ .postgres_password }}@postgresql-default-rw.databases.svc.cluster.local:5432/visual_regression_tracker',
    AWS_ACCESS_KEY_ID: 'visual_regression_tracker',
    AWS_SECRET_ACCESS_KEY: '{{ .seaweedfs_secret_key }}',
    DEFAULT_USER_PASSWORD: '{{ .admin_password }}',
    DEFAULT_USER_API_KEY: '{{ .admin_api_key }}',
  },
}
