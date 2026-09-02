function(app)
  local configmapPlans = (import 'configmap.libsonnet')(app);
  {
    env: [
      {
        name: 'PLAN_CONFIG_FILE',
        value: '/etc/picca/plans/plans.yaml',
      },
    ],
    volumes: [
      {
        name: 'picca-plans',
        configMap: {
          name: configmapPlans.metadata.name,
          items: [
            {
              key: 'plans.yaml',
              path: 'plans.yaml',
            },
          ],
        },
      },
    ],
    volumeMounts: [
      {
        name: 'picca-plans',
        mountPath: '/etc/picca/plans',
        readOnly: true,
      },
    ],
  }
