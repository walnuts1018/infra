local allow = function(actions, resources) {
  Effect: 'Allow',
  Action: actions,
  Resource: resources,
};

local bucketResources = function(bucket) [
  'arn:aws:s3:::' + bucket,
  'arn:aws:s3:::' + bucket + '/*',
];

local allActions = ['s3:*'];
local readOnlyActions = ['s3:Get*', 's3:List*'];
local readWriteActions = [
  's3:Get*',
  's3:Put*',
  's3:Delete*',
  's3:List*',
  's3:*Tagging',
  's3:AbortMultipartUpload',
];

{
  // S3 バケット一覧
  buckets: [
    'cloudnative-pg-backup',
    'ipu',
    'iso',
    'loki-admin',
    'loki-chunks',
    'loki-ruler',
    'misskey',
    'netbox-media',
    'netbox-scripts',
    'oekaki-dengon-game',
    'picca-ai-prototype',
    'pyroscope',
    'stalwart',
    'tempo',
  ],

  // 静的Credential用のIdentity定義
  identities: [
    {
      // Kubernetesリソース名、`^[a-z0-9]([-a-z0-9]*[a-z0-9])?$`
      resourceName: 'terraform',
      // Identity名
      name: 'terraform',
      // BindするS3Policyの名前
      policyName: 'terraform-static',
    },
    {
      resourceName: 'misskey',
      name: 'misskey',
      policyName: 'misskey-static',
    },
    {
      resourceName: 'oekaki-dengon-game',
      name: 'oekaki_dengon_game',
      policyName: 'oekaki-dengon-game-static',
    },
    {
      resourceName: 'stalwart',
      name: 'stalwart',
      policyName: 'stalwart-static',
    },
  ],

  // S3Role CRD がないため、STS ロールが参照するポリシー名は iam.json に出力する。
  // 静的 Identity 用ポリシーは identities の policyName から S3Policy CRD として出力する。
  stsPolicyNames: [
    'DenyAllPolicy',
    'cloudnative-pg-backup',
    'ipu',
    'loki',
    'netbox',
    'picca-ai-prototype-debug-web',
    'picca-ai-prototype-gateway',
    'pyroscope',
    'stalwart',
    'tempo',
  ],

  // S3Policy
  policies: {
    DenyAllPolicy: {
      Version: '2012-10-17',
      Statement: [{
        Effect: 'Deny',
        Action: allActions,
        Resource: ['*'],
      }],
    },
    'cloudnative-pg-backup': {
      Version: '2012-10-17',
      Statement: [
        allow(allActions, bucketResources('cloudnative-pg-backup')),
      ],
    },
    ipu: {
      Version: '2012-10-17',
      Statement: [
        allow(readOnlyActions, bucketResources('ipu')),
      ],
    },
    loki: {
      Version: '2012-10-17',
      Statement: [
        allow(
          allActions,
          std.flattenArrays([bucketResources(bucket) for bucket in ['loki-admin', 'loki-chunks', 'loki-ruler']]),
        ),
      ],
    },
    'misskey-static': {
      Version: '2012-10-17',
      Statement: [
        allow(readWriteActions, bucketResources('misskey')),
      ],
    },
    netbox: {
      Version: '2012-10-17',
      Statement: [
        allow(
          allActions,
          std.flattenArrays([bucketResources(bucket) for bucket in ['netbox-media', 'netbox-scripts']]),
        ),
      ],
    },
    'oekaki-dengon-game-static': {
      Version: '2012-10-17',
      Statement: [
        allow(readWriteActions, bucketResources('oekaki-dengon-game')),
      ],
    },
    'picca-ai-prototype-debug-web': {
      Version: '2012-10-17',
      Statement: [
        allow(['s3:ListBucket'], ['arn:aws:s3:::picca-ai-prototype']),
        allow(['s3:GetObject', 's3:PutObject'], bucketResources('picca-ai-prototype')),
      ],
    },
    'picca-ai-prototype-gateway': {
      Version: '2012-10-17',
      Statement: [
        allow(['s3:ListBucket'], ['arn:aws:s3:::picca-ai-prototype']),
        allow(['s3:GetObject'], bucketResources('picca-ai-prototype')),
      ],
    },
    pyroscope: {
      Version: '2012-10-17',
      Statement: [
        allow(allActions, bucketResources('pyroscope')),
      ],
    },
    stalwart: {
      Version: '2012-10-17',
      Statement: [
        allow(allActions, bucketResources('stalwart')),
      ],
    },
    'stalwart-static': {
      Version: '2012-10-17',
      Statement: [
        allow(readWriteActions, bucketResources('stalwart')),
      ],
    },
    tempo: {
      Version: '2012-10-17',
      Statement: [
        allow(allActions, bucketResources('tempo')),
      ],
    },
    'terraform-static': {
      Version: '2012-10-17',
      Statement: [
        allow(allActions, ['*']),
      ],
    },
  },
}
