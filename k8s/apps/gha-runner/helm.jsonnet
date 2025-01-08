local urls = (import 'urls.libsonnet');
local gen = function(githubConfigUrl)
  (import '../../components/helm.libsonnet') {
    name: std.md5(githubConfigUrl),
    namespace: (import 'app.json5').namespace,

    ociChartURL: 'ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set',
    targetRevision: '0.10.1',
    valuesObject: {
      githubConfigSecret: (import 'external-secret.jsonnet').spec.target.name,
      githubConfigUrl: githubConfigUrl,
      controllerServiceAccount: {
        namespace: (import '../gha-runner-controller/app.json5').namespace,
        name: (import '../gha-runner-controller/app.json5').name + '-gha-rs-controller',
      },
      containerMode: {
        type: 'kubernetes',
        kubernetesModeWorkVolumeClaim: {
          accessModes: ['ReadWriteOnce'],
          storageClassName: 'longhorn',
          resources: {
            requests: {
              storage: '10Gi',
            },
          },
        },
      },
      template: {
        spec: {
          containers: [
            {
              name: 'runner',
              image: 'ghcr.io/actions/actions-runner:latest',
              command: ['/home/runner/run.sh'],
              env: [
                {
                  name: 'ACTIONS_RUNNER_REQUIRE_JOB_CONTAINER',
                  value: 'false',
                },
              ],
            },
          ],
        },
      },
    },
  };

std.map(gen, urls)
