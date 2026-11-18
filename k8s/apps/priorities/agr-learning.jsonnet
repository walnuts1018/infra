{
  apiVersion: 'scheduling.k8s.io/v1',
  kind: 'PriorityClass',
  metadata: {
    name: 'agr-learning',
  },
  value: -100,
  globalDefault: false,
  description: 'agrの通常サービスよりも学習ワークロードの優先度を低く設定する',
}
