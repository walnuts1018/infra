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
        image: 'ghcr.io/cloudnative-pg/postgresql:14.21-standard-trixie',
      },
      {
        major: 15,
        image: 'ghcr.io/cloudnative-pg/postgresql:15.17-standard-trixie',
      },
      {
        major: 16,
        image: 'ghcr.io/cloudnative-pg/postgresql:16.12-standard-trixie',
      },
      {
        major: 17,
        image: 'ghcr.io/cloudnative-pg/postgresql:17.8-standard-trixie',
      },
      {
        major: 18,
        image: 'ghcr.io/cloudnative-pg/postgresql:18.2-standard-trixie',
      },
    ],
  },
}
