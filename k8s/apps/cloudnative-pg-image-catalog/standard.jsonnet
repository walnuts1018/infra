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
        image: 'ghcr.io/cloudnative-pg/postgresql:14.23-standard-trixie',
      },
      {
        major: 15,
        image: 'ghcr.io/cloudnative-pg/postgresql:15.18-standard-trixie',
      },
      {
        major: 16,
        image: 'ghcr.io/cloudnative-pg/postgresql:16.14-standard-trixie',
      },
      {
        major: 17,
        image: 'ghcr.io/cloudnative-pg/postgresql:17.10-standard-trixie',
      },
      {
        major: 18,
        image: 'ghcr.io/cloudnative-pg/postgresql:18.4-standard-trixie',
      },
    ],
  },
}
