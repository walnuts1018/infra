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
        image: 'ghcr.io/cloudnative-pg/postgresql:13.22-standard-trixie',
      },
      {
        major: 14,
        image: 'ghcr.io/cloudnative-pg/postgresql:14.24-standard-trixie',
      },
      {
        major: 15,
        image: 'ghcr.io/cloudnative-pg/postgresql:15.19-standard-trixie',
      },
      {
        major: 16,
        image: 'ghcr.io/cloudnative-pg/postgresql:16.15-standard-trixie',
      },
      {
        major: 17,
        image: 'ghcr.io/cloudnative-pg/postgresql:17.11-standard-trixie',
      },
      {
        major: 18,
        image: 'ghcr.io/cloudnative-pg/postgresql:18.6-standard-trixie',

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
