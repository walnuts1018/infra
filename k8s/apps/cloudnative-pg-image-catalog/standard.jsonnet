{
  apiVersion: 'postgresql.cnpg.io/v1',
  kind: 'ClusterImageCatalog',
  metadata: {
    name: 'standard',
  },
  spec: {
    images: [
      {
        major: 13,
        image: 'ghcr.io/cloudnative-pg/postgresql:13.22-standard-trixie@sha256:8252529362b12a451a18cb19fdec9174ea09709102a7e6cf2e2b24d140dbd181',
      },
      {
        major: 14,
        image: 'ghcr.io/cloudnative-pg/postgresql:14.24-standard-trixie@sha256:9b7fbeb30f13996254d955b2f5ddee15a4a02b5016f870541d7e05d601ff12a7',
      },
      {
        major: 15,
        image: 'ghcr.io/cloudnative-pg/postgresql:15.19-standard-trixie@sha256:8e6ffa486aa444c539a8d6521933891b5df90a63e1f2a35b47354fd738b08532',
      },
      {
        major: 16,
        image: 'ghcr.io/cloudnative-pg/postgresql:16.15-standard-trixie@sha256:d7b23df513a53f3ad8d72004ff2a4bf93eab0b2daa5caa9eedf278b54e883121',
      },
      {
        major: 17,
        image: 'ghcr.io/cloudnative-pg/postgresql:17.11-standard-trixie@sha256:d456fe7392b0b2147b4cea0dc124d51aee7ad3ec522c57f3177799e01f29a2d1',
      },
      {
        major: 18,
        image: 'ghcr.io/cloudnative-pg/postgresql:18.6-standard-trixie@sha256:c7747d8d1049fff9cf30d9cd83d14d609c957afb5ffbcd114145f393ea1850e1',

        extensions: [
          {
            name: 'postgis',
            image: {
              reference: 'ghcr.io/cloudnative-pg/postgis-extension:3.6.4-18-trixie',
            },
            ld_library_path: [
              'system',
            ],
          },
        ],
      },
    ],
  },
}
