{
  avoidSlowNodeAffinity: {
    nodeAffinity: {
      requiredDuringSchedulingIgnoredDuringExecution: {
        nodeSelectorTerms: [
          {
            matchExpressions: [
              {
                key: 'storage.walnuts.dev/slow',
                operator: 'DoesNotExist',
              },
            ],
          },
        ],
      },
    },
  },
}
