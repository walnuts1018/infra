local app = import 'app.json5';
{
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'Application',
  metadata: {
    name: app.name + '-external',
    namespace: 'argocd',
    finalizers: [
      'resources-finalizer.argocd.argoproj.io',
    ],
  },
  spec: {
    project: 'default',
    destination: {
      namespace: app.namespace,
      server: 'https://kubernetes.default.svc',
    },
    source: {
      path: 'deploy',
      repoURL: 'https://github.com/rancher/local-path-provisioner',
      targetRevision: 'v0.0.32',
      kustomize: {
        patches: [
          {
            patch: '$patch: delete\napiVersion: v1\nkind: Namespace\nmetadata:\n  name: local-path-storage',
          },
          {
            target: {
              group: 'apps',
              version: 'v1',
              kind: 'Deployment',
              name: 'local-path-provisioner',
            },
            patch: |||
              - op: add
                path: /spec/template/spec/affinity
                value:
                  nodeAffinity:
                    requiredDuringSchedulingIgnoredDuringExecution:
                      nodeSelectorTerms:
                        - matchExpressions:
                            - key: storage.walnuts.dev/slow
                              operator: DoesNotExist
            |||,
          },
          {
            target: {
              version: 'v1',
              kind: 'ConfigMap',
              name: 'local-path-config',
            },
            patch: |||
              - op: replace
                path: /data/config.json
                value: |-
                  {
                    "nodePathMap": [
                      {
                        "node": "DEFAULT_PATH_FOR_NON_LISTED_NODES",
                        "paths": ["/opt/local-path-provisioner"]
                      },
                      {
                        "node": "rusk",
                        "paths": []
                      }
                    ]
                  }
            |||,
          },
          {
            target: {
              group: 'storage.k8s.io',
              version: 'v1',
              kind: 'StorageClass',
              name: 'local-path',
            },
            patch: |||
              - op: add
                path: /allowedTopologies
                value:
                  - matchLabelExpressions:
                      - key: storage.walnuts.dev/fast
                        values:
                          - "true"
            |||,
          },
        ],
      },
    },
    syncPolicy: {
      automated: {
        selfHeal: true,
        prune: true,
      },
    },
  },
}
