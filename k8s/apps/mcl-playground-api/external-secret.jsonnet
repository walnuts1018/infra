(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'postgres_password',
      remoteRef: {
        key: 'postgres_passwords',
        property: 'mcl_web',
      },
    },
  ],
  template_data: {
    DATABASE_URL: 'postgresql://mcl_web:{{ .postgres_password | urlquery | replace "+" "%20" }}@postgresql-default-rw.databases.svc.cluster.local:5432/mcl_web?sslmode=require&pool_max_conns=4',
  },
}
