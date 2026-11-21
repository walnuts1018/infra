local podSpecPatch = std.manifestJsonEx(import '_workflow_templates/pod-spec-patch.libsonnet', '', '', ':');
local indexedJob = import '_workflow_templates/indexed-job.libsonnet';
local jobReference = import '_workflow_templates/job-reference.libsonnet';
local maxActorPods = 1;
local maxEvaluationPods = 1;
local stagePod = import '_workflow_templates/stage-pod.libsonnet';
{
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'WorkflowTemplate',
  metadata: {
    labels: {
      'workflows.argoproj.io/archive-strategy': 'always',
    },
    name: 'agr-learning',
    namespace: 'agr',
  },
  spec: {
    activeDeadlineSeconds: 1209600,
    arguments: {
      parameters: [
        {
          name: 'trigger',
        },
        {
          name: 'retry-generation-id',
          value: '',
        },
      ],
    },
    entrypoint: 'learning',
    imagePullSecrets: [
      {
        name: 'ghcr-login-secret',
      },
    ],
    onExit: 'cleanup',
    podGC: {
      strategy: 'OnWorkflowCompletion',
    },
    podMetadata: {
      labels: {
        app: 'agr-workflow',
        'app.kubernetes.io/name': 'agr-workflow',
      },
    },
    serviceAccountName: 'agr-workflow',
    executor: { serviceAccountName: 'agr-workflow-executor' },
    synchronization: {
      mutexes: [{ name: 'agr-training' }],
    },
    templates: [
      {
        dag: {
          tasks: [
            {
              arguments: {
                parameters: [
                  { name: 'trigger', value: '{{workflow.parameters.trigger}}' },
                  { name: 'retry-generation-id', value: '{{workflow.parameters.retry-generation-id}}' },
                ],
              },
              name: 'create-attempt',
              template: 'create-attempt',
            },
            {
              depends: 'create-attempt.Succeeded',
              arguments: {
                parameters: [{ name: 'generation-id', value: '{{tasks.create-attempt.outputs.parameters.generation-id}}' }],
              },
              name: 'plan',
              template: 'plan',
              when: '{{tasks.create-attempt.outputs.parameters.skipped}} == false',
            },
            {
              depends: 'plan.Succeeded',
              arguments: {
                parameters: [
                  { name: 'generation-id', value: '{{tasks.plan.outputs.parameters.generation-id}}' },
                  { name: 'config-sha256', value: '{{tasks.plan.outputs.parameters.config-sha256}}' },
                  { name: 'plan-uri', value: '{{tasks.plan.outputs.parameters.plan-uri}}' },
                  { name: 'shard-count', value: '{{tasks.plan.outputs.parameters.rollout-shards}}' },
                  { name: 'actor-pods', value: '{{tasks.plan.outputs.parameters.actor-pods}}' },
                ],
              },
              name: 'rollout',
              template: 'rollout',
            },
            {
              depends: 'rollout.Succeeded',
              arguments: {
                parameters: [
                  { name: 'generation-id', value: '{{tasks.plan.outputs.parameters.generation-id}}' },
                  { name: 'plan-uri', value: '{{tasks.plan.outputs.parameters.plan-uri}}' },
                ],
              },
              name: 'dataset',
              template: 'dataset',
            },
            {
              depends: 'dataset.Succeeded',
              arguments: {
                parameters: [
                  { name: 'generation-id', value: '{{tasks.plan.outputs.parameters.generation-id}}' },
                  { name: 'plan-uri', value: '{{tasks.plan.outputs.parameters.plan-uri}}' },
                  { name: 'dataset-uri', value: '{{tasks.dataset.outputs.parameters.dataset-uri}}' },
                  { name: 'learner-artifact-uri', value: '{{tasks.plan.outputs.parameters.learner-artifact-uri}}' },
                  { name: 'learner-sha256', value: '{{tasks.plan.outputs.parameters.learner-sha256}}' },
                ],
              },
              name: 'train',
              template: 'train',
            },
            {
              depends: 'train.Succeeded',
              arguments: {
                parameters: [
                  { name: 'generation-id', value: '{{tasks.plan.outputs.parameters.generation-id}}' },
                  { name: 'plan-uri', value: '{{tasks.plan.outputs.parameters.plan-uri}}' },
                ],
              },
              name: 'validate',
              template: 'validate',
            },
            {
              depends: 'validate.Succeeded',
              arguments: {
                parameters: [
                  { name: 'generation-id', value: '{{tasks.plan.outputs.parameters.generation-id}}' },
                  { name: 'config-sha256', value: '{{tasks.plan.outputs.parameters.config-sha256}}' },
                  { name: 'plan-uri', value: '{{tasks.plan.outputs.parameters.plan-uri}}' },
                  { name: 'shard-count', value: '{{tasks.plan.outputs.parameters.evaluation-shards}}' },
                  { name: 'evaluation-pods', value: '{{tasks.plan.outputs.parameters.evaluation-pods}}' },
                  { name: 'artifact-uri', value: '{{tasks.validate.outputs.parameters.artifact-uri}}' },
                  { name: 'model-sha256', value: '{{tasks.validate.outputs.parameters.model-sha256}}' },
                  { name: 'manifest-sha256', value: '{{tasks.validate.outputs.parameters.manifest-sha256}}' },
                  { name: 'validation-uri', value: '{{tasks.validate.outputs.parameters.validation-uri}}' },
                ],
              },
              name: 'assess',
              template: 'assess',
            },
            {
              depends: 'assess.Succeeded',
              arguments: {
                parameters: [
                  { name: 'generation-id', value: '{{tasks.plan.outputs.parameters.generation-id}}' },
                  { name: 'plan-uri', value: '{{tasks.plan.outputs.parameters.plan-uri}}' },
                ],
              },
              name: 'aggregate',
              template: 'aggregate',
            },
            {
              depends: 'aggregate.Succeeded',
              arguments: {
                parameters: [
                  { name: 'generation-id', value: '{{tasks.plan.outputs.parameters.generation-id}}' },
                  { name: 'plan-uri', value: '{{tasks.plan.outputs.parameters.plan-uri}}' },
                  { name: 'report-uri', value: '{{tasks.aggregate.outputs.parameters.report-uri}}' },
                ],
              },
              name: 'decide',
              template: 'decide',
            },
            {
              depends: 'decide.Succeeded',
              arguments: {
                parameters: [
                  { name: 'generation-id', value: '{{tasks.plan.outputs.parameters.generation-id}}' },
                  { name: 'plan-uri', value: '{{tasks.plan.outputs.parameters.plan-uri}}' },
                  { name: 'report-uri', value: '{{tasks.aggregate.outputs.parameters.report-uri}}' },
                  { name: 'model-id', value: '{{tasks.train.outputs.parameters.model-id}}' },
                ],
              },
              name: 'publish',
              template: 'publish',
              when: '{{tasks.decide.outputs.parameters.promote}} == true',
            },
            {
              depends: 'publish.Succeeded',
              arguments: {
                parameters: [
                  { name: 'generation-id', value: '{{tasks.plan.outputs.parameters.generation-id}}' },
                  { name: 'plan-uri', value: '{{tasks.plan.outputs.parameters.plan-uri}}' },
                ],
              },
              name: 'verify',
              template: 'verify',
            },
          ],
        },
        name: 'learning',
      },
      {
        inputs: {
          parameters: [{ name: 'generation-id' }],
        },
        name: 'plan',
        outputs: {
          parameters: [
            {
              name: 'generation-id',
              valueFrom: {
                path: '/tmp/plan-output/generation-id',
              },
            },
            {
              name: 'generation-number',
              valueFrom: {
                path: '/tmp/plan-output/generation-number',
              },
            },
            {
              name: 'attempt-id',
              valueFrom: {
                path: '/tmp/plan-output/attempt-id',
              },
            },
            {
              name: 'config-sha256',
              valueFrom: {
                path: '/tmp/plan-output/config-sha256',
              },
            },
            {
              name: 'plan-uri',
              valueFrom: {
                path: '/tmp/plan-output/plan-uri',
              },
            },
            {
              name: 'rollout-shards',
              valueFrom: {
                path: '/tmp/plan-output/rollout-shards',
              },
            },
            {
              name: 'actor-pods',
              valueFrom: {
                path: '/tmp/plan-output/actor-pods',
              },
            },
            {
              name: 'evaluation-shards',
              valueFrom: {
                path: '/tmp/plan-output/evaluation-shards',
              },
            },
            {
              name: 'evaluation-pods',
              valueFrom: {
                path: '/tmp/plan-output/evaluation-pods',
              },
            },
            {
              name: 'learner-artifact-uri',
              valueFrom: {
                path: '/tmp/plan-output/learner-artifact-uri',
              },
            },
            {
              name: 'learner-sha256',
              valueFrom: {
                path: '/tmp/plan-output/learner-sha256',
              },
            },
          ],
        },
        podSpecPatch: podSpecPatch,
        container: {
          command: ['/app/.venv/bin/agr-plan'],
          args: [
            '--argo-output-dir',
            '/tmp/plan-output',
            '--max-actor-pods',
            std.toString(maxActorPods),
            '--max-evaluation-pods',
            std.toString(maxEvaluationPods),
          ],
          env: stagePod.s3Env('agr-planner', 'agr-planner', [
            {
              name: 'AWS_ENDPOINT_URL_S3',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
            },
            {
              name: 'AWS_ENDPOINT_URL_STS',
              value: 'https://seaweedfs.local.walnuts.dev',
            },
            {
              name: 'AWS_ROLE_ARN',
              value: 'arn:aws:iam::role/agr-planner',
            },
            {
              name: 'AWS_WEB_IDENTITY_TOKEN_FILE',
              value: '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token',
            },
            {
              name: 'AWS_REGION',
              value: 'us-east-1',
            },
            {
              name: 'WORKER_S3_BUCKET',
              value: 'agr-ai',
            },
            {
              name: 'WORKER_S3_PREFIX',
              value: 'worker-runs',
            },
            {
              name: 'WORKER_CONTROLLER_ID',
              value: 'agr-planner',
            },
            {
              name: 'SERVICE_ENDPOINT',
              value: 'http://agr-server.agr.svc.cluster.local:8080',
            },
            {
              name: 'SERVICE_GATEWAY_TOKEN',
              valueFrom: {
                secretKeyRef: {
                  key: 'SERVICE_GATEWAY_TOKEN',
                  name: 'agr-learning-token',
                },
              },
            },
            {
              name: 'AGR_TRAINING_IMAGE_REFERENCE',
              value: 'ghcr.io/walnuts1018/agr-training:0.1.45@sha256:c2cd3c27105d65c1235f84805cfb6d14c7836bde228fe1a6e329f09eed589009',
            },
            {
              name: 'AGR_WORKFLOW_UID',
              value: '{{workflow.uid}}',
            },
            {
              name: 'AGR_WORKFLOW_GENERATION_ID',
              value: '{{inputs.parameters.generation-id}}',
            },
          ]),
          image: 'ghcr.io/walnuts1018/agr-training:0.1.45@sha256:c2cd3c27105d65c1235f84805cfb6d14c7836bde228fe1a6e329f09eed589009',
          resources: {
            limits: {
              cpu: '500m',
              'ephemeral-storage': '1Gi',
              memory: '4Gi',
            },
            requests: {
              cpu: '100m',
              'ephemeral-storage': '128Mi',
              memory: '1Gi',
            },
          },
          securityContext: stagePod.securityContext,
          volumeMounts: stagePod.volumeMounts,
        },
        serviceAccountName: 'agr-planner',
        volumes: stagePod.volumes('1Gi'),
      },
      {
        inputs: {
          parameters: [
            { name: 'generation-id' },
            { name: 'config-sha256' },
            { name: 'plan-uri' },
            { name: 'shard-count' },
            { name: 'actor-pods' },
          ],
        },
        name: 'rollout',
        dag: {
          tasks: [
            {
              name: 'apply-job',
              template: 'apply-rollout-job',
              arguments: {
                parameters: [
                  { name: 'generation-id', value: '{{inputs.parameters.generation-id}}' },
                  { name: 'config-sha256', value: '{{inputs.parameters.config-sha256}}' },
                  { name: 'plan-uri', value: '{{inputs.parameters.plan-uri}}' },
                  { name: 'shard-count', value: '{{inputs.parameters.shard-count}}' },
                  { name: 'actor-pods', value: '{{inputs.parameters.actor-pods}}' },
                ],
              },
            },
            {
              name: 'wait-indexed-job',
              template: 'wait-rollout-indexed-job',
              dependencies: ['apply-job'],
              arguments: {
                parameters: [{ name: 'shard-count', value: '{{inputs.parameters.shard-count}}' }],
              },
            },
          ],
        },
      },
      {
        inputs: {
          parameters: [
            { name: 'generation-id' },
            { name: 'plan-uri' },
          ],
        },
        name: 'dataset',
        podSpecPatch: podSpecPatch,
        serviceAccountName: 'agr-dataset',
        volumes: stagePod.volumes('4Gi'),
        container: {
          image: 'ghcr.io/walnuts1018/agr-training:0.1.45@sha256:c2cd3c27105d65c1235f84805cfb6d14c7836bde228fe1a6e329f09eed589009',
          command: ['/app/.venv/bin/agr-build-dataset'],
          args: ['--argo-output-dir', '/tmp/dataset-output'],
          env: stagePod.s3Env('agr-dataset', 'agr-dataset', [
            {
              name: 'AWS_ENDPOINT_URL_S3',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
            },
            {
              name: 'AWS_ENDPOINT_URL_STS',
              value: 'https://seaweedfs.local.walnuts.dev',
            },
            {
              name: 'AWS_ROLE_ARN',
              value: 'arn:aws:iam::role/agr-dataset',
            },
            {
              name: 'AWS_WEB_IDENTITY_TOKEN_FILE',
              value: '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token',
            },
            {
              name: 'AWS_REGION',
              value: 'us-east-1',
            },
            {
              name: 'WORKER_S3_BUCKET',
              value: 'agr-ai',
            },
            {
              name: 'WORKER_S3_PREFIX',
              value: 'worker-runs',
            },
            {
              name: 'WORKER_S3_ENDPOINT',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
            },
            {
              name: 'WORKER_CONTROLLER_ID',
              value: 'agr-dataset',
            },
            {
              name: 'SERVICE_ENDPOINT',
              value: 'http://agr-server.agr.svc.cluster.local:8080',
            },
            {
              name: 'SERVICE_GATEWAY_TOKEN',
              valueFrom: {
                secretKeyRef: {
                  name: 'agr-learning-token',
                  key: 'SERVICE_GATEWAY_TOKEN',
                },
              },
            },
            {
              name: 'OMP_NUM_THREADS',
              value: '1',
            },
            {
              name: 'MKL_NUM_THREADS',
              value: '1',
            },
            {
              name: 'AGR_TRAINING_IMAGE_REFERENCE',
              value: 'ghcr.io/walnuts1018/agr-training:0.1.45@sha256:c2cd3c27105d65c1235f84805cfb6d14c7836bde228fe1a6e329f09eed589009',
            },
            {
              name: 'AGR_WORKFLOW_UID',
              value: '{{workflow.uid}}',
            },
            {
              name: 'AGR_WORKFLOW_GENERATION_ID',
              value: '{{inputs.parameters.generation-id}}',
            },
            {
              name: 'AGR_WORKFLOW_PLAN_URI',
              value: '{{inputs.parameters.plan-uri}}',
            },
          ]),
          resources: {
            limits: {
              cpu: '500m',
              'ephemeral-storage': '4Gi',
              memory: '1Gi',
            },
            requests: {
              cpu: '100m',
              'ephemeral-storage': '512Mi',
              memory: '256Mi',
            },
          },
          securityContext: stagePod.securityContext,
          volumeMounts: stagePod.volumeMounts,
        },
        outputs: {
          parameters: [
            {
              name: 'dataset-uri',
              valueFrom: {
                path: '/tmp/dataset-output/dataset-uri',
              },
            },
          ],
        },
      },
      {
        inputs: {
          parameters: [
            { name: 'generation-id' },
            { name: 'plan-uri' },
            { name: 'dataset-uri' },
            { name: 'learner-artifact-uri' },
            { name: 'learner-sha256' },
          ],
        },
        name: 'train',
        podSpecPatch: podSpecPatch,
        serviceAccountName: 'agr-trainer',
        volumes: stagePod.volumes('10Gi'),
        container: {
          image: 'ghcr.io/walnuts1018/agr-training:0.1.45@sha256:c2cd3c27105d65c1235f84805cfb6d14c7836bde228fe1a6e329f09eed589009',
          command: ['/app/.venv/bin/agr-train'],
          args: [
            '--s3-input-uri',
            '{{inputs.parameters.dataset-uri}}',
            '--s3-output-uri',
            's3://agr-ai/worker-runs/models/candidates/{{inputs.parameters.generation-id}}',
            '--initial-artifact-uri',
            '{{inputs.parameters.learner-artifact-uri}}',
            '--behavior-policy-id',
            'shared-policy-v3',
            '--behavior-policy-artifact-sha256',
            '{{inputs.parameters.learner-sha256}}',
            '--argo-output-dir',
            '/tmp/train-output',
          ],
          env: stagePod.s3Env('agr-trainer', 'agr-trainer', [
            { name: 'SERVICE_ENDPOINT', value: 'http://agr-server.agr.svc.cluster.local:8080' },
            {
              name: 'SERVICE_GATEWAY_TOKEN',
              valueFrom: { secretKeyRef: { name: 'agr-learning-token', key: 'SERVICE_GATEWAY_TOKEN' } },
            },
            { name: 'WORKER_CONTROLLER_ID', value: 'agr-trainer' },
            {
              name: 'AWS_ENDPOINT_URL_S3',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
            },
            {
              name: 'AWS_ENDPOINT_URL_STS',
              value: 'https://seaweedfs.local.walnuts.dev',
            },
            {
              name: 'AWS_ROLE_ARN',
              value: 'arn:aws:iam::role/agr-trainer',
            },
            {
              name: 'AWS_WEB_IDENTITY_TOKEN_FILE',
              value: '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token',
            },
            {
              name: 'AWS_REGION',
              value: 'us-east-1',
            },
            {
              name: 'WORKER_S3_BUCKET',
              value: 'agr-ai',
            },
            {
              name: 'WORKER_S3_PREFIX',
              value: 'worker-runs',
            },
            {
              name: 'OMP_NUM_THREADS',
              value: '2',
            },
            {
              name: 'MKL_NUM_THREADS',
              value: '2',
            },
            {
              name: 'OPENBLAS_NUM_THREADS',
              value: '2',
            },
            {
              name: 'TORCH_NUM_THREADS',
              value: '2',
            },
            {
              name: 'AGR_TRAINING_IMAGE_REFERENCE',
              value: 'ghcr.io/walnuts1018/agr-training:0.1.45@sha256:c2cd3c27105d65c1235f84805cfb6d14c7836bde228fe1a6e329f09eed589009',
            },
            {
              name: 'AGR_WORKFLOW_UID',
              value: '{{workflow.uid}}',
            },
            {
              name: 'AGR_WORKFLOW_GENERATION_ID',
              value: '{{inputs.parameters.generation-id}}',
            },
            {
              name: 'AGR_WORKFLOW_PLAN_URI',
              value: '{{inputs.parameters.plan-uri}}',
            },
            {
              name: 'AGR_WORKFLOW_INPUT_URI',
              value: '{{inputs.parameters.dataset-uri}}',
            },
            {
              name: 'AGR_WORKFLOW_OUTPUT_URI',
              value: 's3://agr-ai/worker-runs/models/candidates/{{inputs.parameters.generation-id}}',
            },
            {
              name: 'AGR_WORKFLOW_LEARNER_URI',
              value: '{{inputs.parameters.learner-artifact-uri}}',
            },
            {
              name: 'AGR_WORKFLOW_LEARNER_SHA256',
              value: '{{inputs.parameters.learner-sha256}}',
            },
            {
              name: 'AGR_WORKFLOW_BEHAVIOR_POLICY_SHA256',
              value: '{{inputs.parameters.learner-sha256}}',
            },
          ]),
          resources: {
            limits: {
              cpu: '2',
              'ephemeral-storage': '10Gi',
              memory: '6144Mi',
            },
            requests: {
              cpu: '2',
              'ephemeral-storage': '2Gi',
              memory: '6144Mi',
            },
          },
          securityContext: stagePod.securityContext,
          volumeMounts: stagePod.volumeMounts,
        },
        outputs: {
          parameters: [
            {
              name: 'artifact-uri',
              valueFrom: {
                path: '/tmp/train-output/artifact-uri',
              },
            },
            {
              name: 'model-sha256',
              valueFrom: {
                path: '/tmp/train-output/model-sha256',
              },
            },
            {
              name: 'manifest-sha256',
              valueFrom: {
                path: '/tmp/train-output/manifest-sha256',
              },
            },
            {
              name: 'model-id',
              valueFrom: {
                path: '/tmp/train-output/model-id',
              },
            },
          ],
        },
      },
      {
        inputs: {
          parameters: [
            { name: 'generation-id' },
            { name: 'plan-uri' },
          ],
        },
        name: 'validate',
        outputs: {
          parameters: [
            {
              name: 'artifact-uri',
              valueFrom: {
                path: '/tmp/validate-output/artifact-uri',
              },
            },
            {
              name: 'model-sha256',
              valueFrom: {
                path: '/tmp/validate-output/model-sha256',
              },
            },
            {
              name: 'manifest-sha256',
              valueFrom: {
                path: '/tmp/validate-output/manifest-sha256',
              },
            },
            {
              name: 'validation-uri',
              valueFrom: {
                path: '/tmp/validate-output/validation-uri',
              },
            },
          ],
        },
        podSpecPatch: podSpecPatch,
        container: {
          command: ['/app/.venv/bin/agr-validate'],
          args: ['--argo-output-dir', '/tmp/validate-output'],
          env: stagePod.s3Env('agr-validator', 'agr-validator', [
            {
              name: 'AWS_ENDPOINT_URL_S3',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
            },
            {
              name: 'AWS_ENDPOINT_URL_STS',
              value: 'https://seaweedfs.local.walnuts.dev',
            },
            {
              name: 'AWS_ROLE_ARN',
              value: 'arn:aws:iam::role/agr-validator',
            },
            {
              name: 'AWS_WEB_IDENTITY_TOKEN_FILE',
              value: '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token',
            },
            {
              name: 'AWS_REGION',
              value: 'us-east-1',
            },
            {
              name: 'WORKER_S3_BUCKET',
              value: 'agr-ai',
            },
            {
              name: 'WORKER_S3_PREFIX',
              value: 'worker-runs',
            },
            {
              name: 'AGR_TRAINING_IMAGE_REFERENCE',
              value: 'ghcr.io/walnuts1018/agr-training:0.1.45@sha256:c2cd3c27105d65c1235f84805cfb6d14c7836bde228fe1a6e329f09eed589009',
            },
            {
              name: 'AGR_WORKFLOW_UID',
              value: '{{workflow.uid}}',
            },
            {
              name: 'AGR_WORKFLOW_GENERATION_ID',
              value: '{{inputs.parameters.generation-id}}',
            },
            {
              name: 'AGR_WORKFLOW_PLAN_URI',
              value: '{{inputs.parameters.plan-uri}}',
            },
          ]),
          image: 'ghcr.io/walnuts1018/agr-training:0.1.45@sha256:c2cd3c27105d65c1235f84805cfb6d14c7836bde228fe1a6e329f09eed589009',
          resources: {
            limits: {
              cpu: '500m',
              'ephemeral-storage': '2Gi',
              memory: '1Gi',
            },
            requests: {
              cpu: '100m',
              'ephemeral-storage': '512Mi',
              memory: '256Mi',
            },
          },
          securityContext: stagePod.securityContext,
          volumeMounts: stagePod.volumeMounts,
        },
        serviceAccountName: 'agr-validator',
        volumes: stagePod.volumes('2Gi'),
      },
      {
        inputs: {
          parameters: [
            { name: 'generation-id' },
            { name: 'config-sha256' },
            { name: 'plan-uri' },
            { name: 'shard-count' },
            { name: 'evaluation-pods' },
            { name: 'artifact-uri' },
            { name: 'model-sha256' },
            { name: 'manifest-sha256' },
            { name: 'validation-uri' },
          ],
        },
        name: 'assess',
        dag: {
          tasks: [
            {
              name: 'apply-job',
              template: 'apply-assess-job',
              arguments: {
                parameters: [
                  { name: 'generation-id', value: '{{inputs.parameters.generation-id}}' },
                  { name: 'config-sha256', value: '{{inputs.parameters.config-sha256}}' },
                  { name: 'plan-uri', value: '{{inputs.parameters.plan-uri}}' },
                  { name: 'shard-count', value: '{{inputs.parameters.shard-count}}' },
                  { name: 'evaluation-pods', value: '{{inputs.parameters.evaluation-pods}}' },
                  { name: 'artifact-uri', value: '{{inputs.parameters.artifact-uri}}' },
                  { name: 'model-sha256', value: '{{inputs.parameters.model-sha256}}' },
                  { name: 'manifest-sha256', value: '{{inputs.parameters.manifest-sha256}}' },
                  { name: 'validation-uri', value: '{{inputs.parameters.validation-uri}}' },
                ],
              },
            },
            {
              name: 'wait-indexed-job',
              template: 'wait-assess-indexed-job',
              dependencies: ['apply-job'],
              arguments: {
                parameters: [{ name: 'shard-count', value: '{{inputs.parameters.shard-count}}' }],
              },
            },
          ],
        },
      },
      {
        inputs: {
          parameters: [
            { name: 'generation-id' },
            { name: 'plan-uri' },
          ],
        },
        name: 'aggregate',
        outputs: {
          parameters: [
            {
              name: 'report-uri',
              valueFrom: {
                path: '/tmp/aggregate-output/report-uri',
              },
            },
          ],
        },
        podSpecPatch: podSpecPatch,
        container: {
          command: ['/app/.venv/bin/agr-aggregate-evaluation'],
          args: ['--argo-output-dir', '/tmp/aggregate-output'],
          env: stagePod.s3Env('agr-evaluator', 'agr-evaluator', [
            {
              name: 'AWS_ENDPOINT_URL_S3',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
            },
            {
              name: 'AWS_ENDPOINT_URL_STS',
              value: 'https://seaweedfs.local.walnuts.dev',
            },
            {
              name: 'AWS_ROLE_ARN',
              value: 'arn:aws:iam::role/agr-evaluator',
            },
            {
              name: 'AWS_WEB_IDENTITY_TOKEN_FILE',
              value: '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token',
            },
            {
              name: 'AWS_REGION',
              value: 'us-east-1',
            },
            {
              name: 'WORKER_S3_BUCKET',
              value: 'agr-ai',
            },
            {
              name: 'WORKER_S3_PREFIX',
              value: 'worker-runs',
            },
            {
              name: 'AGR_TRAINING_IMAGE_REFERENCE',
              value: 'ghcr.io/walnuts1018/agr-training:0.1.45@sha256:c2cd3c27105d65c1235f84805cfb6d14c7836bde228fe1a6e329f09eed589009',
            },
            {
              name: 'AGR_WORKFLOW_UID',
              value: '{{workflow.uid}}',
            },
            {
              name: 'AGR_WORKFLOW_GENERATION_ID',
              value: '{{inputs.parameters.generation-id}}',
            },
            {
              name: 'AGR_WORKFLOW_PLAN_URI',
              value: '{{inputs.parameters.plan-uri}}',
            },
          ]),
          image: 'ghcr.io/walnuts1018/agr-training:0.1.45@sha256:c2cd3c27105d65c1235f84805cfb6d14c7836bde228fe1a6e329f09eed589009',
          resources: {
            limits: {
              cpu: '500m',
              'ephemeral-storage': '2Gi',
              memory: '1Gi',
            },
            requests: {
              cpu: '100m',
              'ephemeral-storage': '512Mi',
              memory: '256Mi',
            },
          },
          securityContext: stagePod.securityContext,
          volumeMounts: stagePod.volumeMounts,
        },
        serviceAccountName: 'agr-evaluator',
        volumes: stagePod.volumes('2Gi'),
      },
      {
        inputs: {
          parameters: [
            { name: 'generation-id' },
            { name: 'plan-uri' },
            { name: 'report-uri' },
          ],
        },
        name: 'decide',
        outputs: {
          parameters: [
            {
              globalName: 'promote',
              name: 'promote',
              valueFrom: {
                path: '/tmp/decision-output/promote',
              },
            },
          ],
        },
        podSpecPatch: podSpecPatch,
        container: {
          command: ['/app/.venv/bin/agr-decide-promotion'],
          args: ['--argo-output-dir', '/tmp/decision-output'],
          env: stagePod.s3Env('agr-evaluator', 'agr-evaluator', [
            {
              name: 'AWS_ENDPOINT_URL_S3',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
            },
            {
              name: 'AWS_ENDPOINT_URL_STS',
              value: 'https://seaweedfs.local.walnuts.dev',
            },
            {
              name: 'AWS_ROLE_ARN',
              value: 'arn:aws:iam::role/agr-evaluator',
            },
            {
              name: 'AWS_WEB_IDENTITY_TOKEN_FILE',
              value: '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token',
            },
            {
              name: 'AWS_REGION',
              value: 'us-east-1',
            },
            {
              name: 'WORKER_S3_BUCKET',
              value: 'agr-ai',
            },
            {
              name: 'WORKER_S3_PREFIX',
              value: 'worker-runs',
            },
            {
              name: 'AGR_TRAINING_IMAGE_REFERENCE',
              value: 'ghcr.io/walnuts1018/agr-training:0.1.45@sha256:c2cd3c27105d65c1235f84805cfb6d14c7836bde228fe1a6e329f09eed589009',
            },
            {
              name: 'AGR_WORKFLOW_UID',
              value: '{{workflow.uid}}',
            },
            {
              name: 'AGR_WORKFLOW_GENERATION_ID',
              value: '{{inputs.parameters.generation-id}}',
            },
            {
              name: 'AGR_WORKFLOW_PLAN_URI',
              value: '{{inputs.parameters.plan-uri}}',
            },
            {
              name: 'AGR_EVALUATION_REPORT_URI',
              value: '{{inputs.parameters.report-uri}}',
            },
          ]),
          image: 'ghcr.io/walnuts1018/agr-training:0.1.45@sha256:c2cd3c27105d65c1235f84805cfb6d14c7836bde228fe1a6e329f09eed589009',
          resources: {
            limits: {
              cpu: '500m',
              'ephemeral-storage': '1Gi',
              memory: '1Gi',
            },
            requests: {
              cpu: '100m',
              'ephemeral-storage': '128Mi',
              memory: '128Mi',
            },
          },
          securityContext: stagePod.securityContext,
          volumeMounts: stagePod.volumeMounts,
        },
        serviceAccountName: 'agr-evaluator',
        volumes: stagePod.volumes('1Gi'),
      },
      {
        container: {
          args: [
            '--target-id',
            '{{inputs.parameters.model-id}}',
            '--active-pointer-s3-uri',
            's3://agr-ai/worker-runs/models/active.json',
          ],
          command: [
            '/app/.venv/bin/agr-publish',
          ],
          env: stagePod.s3Env('agr-promoter', 'agr-promoter', [
            { name: 'SERVICE_ENDPOINT', value: 'http://agr-server.agr.svc.cluster.local:8080' },
            {
              name: 'SERVICE_GATEWAY_TOKEN',
              valueFrom: { secretKeyRef: { name: 'agr-learning-token', key: 'SERVICE_GATEWAY_TOKEN' } },
            },
            { name: 'WORKER_CONTROLLER_ID', value: 'agr-promoter' },
            {
              name: 'AWS_ENDPOINT_URL_S3',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
            },
            {
              name: 'AWS_ENDPOINT_URL_STS',
              value: 'https://seaweedfs.local.walnuts.dev',
            },
            {
              name: 'AWS_ROLE_ARN',
              value: 'arn:aws:iam::role/agr-promoter',
            },
            {
              name: 'AWS_WEB_IDENTITY_TOKEN_FILE',
              value: '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token',
            },
            {
              name: 'AWS_REGION',
              value: 'us-east-1',
            },
            {
              name: 'WORKER_S3_BUCKET',
              value: 'agr-ai',
            },
            {
              name: 'WORKER_S3_PREFIX',
              value: 'worker-runs',
            },
            {
              name: 'AGR_TRAINING_IMAGE_REFERENCE',
              value: 'ghcr.io/walnuts1018/agr-training:0.1.45@sha256:c2cd3c27105d65c1235f84805cfb6d14c7836bde228fe1a6e329f09eed589009',
            },
            {
              name: 'AGR_WORKFLOW_UID',
              value: '{{workflow.uid}}',
            },
            {
              name: 'AGR_EVALUATION_REPORT_URI',
              value: '{{inputs.parameters.report-uri}}',
            },
            {
              name: 'AGR_WORKFLOW_GENERATION_ID',
              value: '{{inputs.parameters.generation-id}}',
            },
            {
              name: 'AGR_WORKFLOW_PLAN_URI',
              value: '{{inputs.parameters.plan-uri}}',
            },
          ]),
          image: 'ghcr.io/walnuts1018/agr-training:0.1.45@sha256:c2cd3c27105d65c1235f84805cfb6d14c7836bde228fe1a6e329f09eed589009',
          resources: {
            limits: {
              cpu: '500m',
              'ephemeral-storage': '2Gi',
              memory: '1Gi',
            },
            requests: {
              cpu: '100m',
              'ephemeral-storage': '512Mi',
              memory: '256Mi',
            },
          },
          securityContext: stagePod.securityContext,
          volumeMounts: stagePod.volumeMounts,
        },
        inputs: {
          parameters: [
            { name: 'generation-id' },
            { name: 'plan-uri' },
            { name: 'report-uri' },
            { name: 'model-id' },
          ],
        },
        name: 'publish',
        podSpecPatch: podSpecPatch,
        serviceAccountName: 'agr-promoter',
        volumes: stagePod.volumes('2Gi'),
      },
      {
        container: {
          args: [
          ],
          command: [
            '/app/.venv/bin/agr-verify-deployment',
          ],
          env: stagePod.s3Env('agr-verify', 'agr-verify', [
            {
              name: 'AWS_ENDPOINT_URL_S3',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
            },
            {
              name: 'AWS_ENDPOINT_URL_STS',
              value: 'https://seaweedfs.local.walnuts.dev',
            },
            {
              name: 'AWS_ROLE_ARN',
              value: 'arn:aws:iam::role/agr-verify',
            },
            {
              name: 'AWS_WEB_IDENTITY_TOKEN_FILE',
              value: '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token',
            },
            {
              name: 'AWS_REGION',
              value: 'us-east-1',
            },
            {
              name: 'WORKER_S3_BUCKET',
              value: 'agr-ai',
            },
            {
              name: 'WORKER_S3_PREFIX',
              value: 'worker-runs',
            },
            {
              name: 'AGR_TRAINING_IMAGE_REFERENCE',
              value: 'ghcr.io/walnuts1018/agr-training:0.1.45@sha256:c2cd3c27105d65c1235f84805cfb6d14c7836bde228fe1a6e329f09eed589009',
            },
            {
              name: 'AGR_WORKFLOW_UID',
              value: '{{workflow.uid}}',
            },
            {
              name: 'AGR_WORKFLOW_GENERATION_ID',
              value: '{{inputs.parameters.generation-id}}',
            },
            {
              name: 'AGR_WORKFLOW_PLAN_URI',
              value: '{{inputs.parameters.plan-uri}}',
            },
            {
              name: 'AGR_SERVER_SERVICE_HEALTH_URL',
              value: 'http://agr-server.agr.svc.cluster.local:8081',
            },
          ]),
          image: 'ghcr.io/walnuts1018/agr-training:0.1.45@sha256:c2cd3c27105d65c1235f84805cfb6d14c7836bde228fe1a6e329f09eed589009',
          resources: {
            limits: {
              cpu: '500m',
              'ephemeral-storage': '1Gi',
              memory: '1Gi',
            },
            requests: {
              cpu: '100m',
              'ephemeral-storage': '128Mi',
              memory: '256Mi',
            },
          },
          securityContext: stagePod.securityContext,
          volumeMounts: stagePod.volumeMounts,
        },
        inputs: {
          parameters: [
            { name: 'generation-id' },
            { name: 'plan-uri' },
          ],
        },
        name: 'verify',
        podSpecPatch: podSpecPatch,
        serviceAccountName: 'agr-verify',
        volumes: stagePod.volumes('1Gi'),
      },
      {
        inputs: {
          parameters: [
            { name: 'generation-id' },
            { name: 'config-sha256' },
            { name: 'plan-uri' },
            { name: 'shard-count' },
            { name: 'actor-pods' },
          ],
        },
        name: 'apply-rollout-job',
        resource: {
          action: 'apply',
          manifest: indexedJob.render({
            stage: 'rollout',
            stageLabel: 'rollout',
            parallelismParameter: 'actor-pods',
            serviceAccount: 'agr-actor',
            containerName: 'actor',
            command: 'run-shard',
            commandArgs: [],
            controllerId: 'agr-actor',
            extraEnv: [{ name: 'OMP_NUM_THREADS', value: '1' }],
          }),
          setOwnerReference: true,
        },
      },
      {
        inputs: {
          parameters: [{ name: 'shard-count' }],
        },
        name: 'wait-rollout-indexed-job',
        resource: {
          action: 'get',
          failureCondition: import '_workflow_templates/indexed-job-failure-condition.libsonnet',
          manifest: jobReference.manifest('rollout'),
          successCondition: 'status.succeeded == {{inputs.parameters.shard-count}}',
        },
      },
      {
        inputs: {
          parameters: [
            { name: 'generation-id' },
            { name: 'config-sha256' },
            { name: 'plan-uri' },
            { name: 'shard-count' },
            { name: 'evaluation-pods' },
            { name: 'artifact-uri' },
            { name: 'model-sha256' },
            { name: 'manifest-sha256' },
            { name: 'validation-uri' },
          ],
        },
        name: 'apply-assess-job',
        resource: {
          action: 'apply',
          manifest: indexedJob.render({
            stage: 'assess',
            stageLabel: 'evaluation',
            parallelismParameter: 'evaluation-pods',
            serviceAccount: 'agr-evaluator',
            containerName: 'evaluator',
            command: 'evaluate-shard',
            commandArgs: [],
            controllerId: 'agr-evaluator',
            extraEnv: [
              { name: 'AGR_CANDIDATE_MODEL_URI', value: '{{inputs.parameters.artifact-uri}}' },
              { name: 'AGR_CANDIDATE_MODEL_SHA256', value: '{{inputs.parameters.model-sha256}}' },
              { name: 'AGR_CANDIDATE_MANIFEST_SHA256', value: '{{inputs.parameters.manifest-sha256}}' },
              { name: 'AGR_CANDIDATE_VALIDATION_URI', value: '{{inputs.parameters.validation-uri}}' },
            ],
          }),
          setOwnerReference: true,
        },
      },
      {
        inputs: {
          parameters: [{ name: 'shard-count' }],
        },
        name: 'wait-assess-indexed-job',
        resource: {
          action: 'get',
          failureCondition: import '_workflow_templates/indexed-job-failure-condition.libsonnet',
          manifest: jobReference.manifest('assess'),
          successCondition: 'status.succeeded == {{inputs.parameters.shard-count}}',
        },
      },
      {
        dag: {
          failFast: false,
          tasks: [
            {
              name: 'delete-rollout',
              template: 'delete-rollout',
            },
            {
              name: 'delete-assess',
              template: 'delete-assess',
            },
            {
              depends: '(delete-rollout.Succeeded || delete-rollout.Failed || delete-rollout.Errored || delete-rollout.Skipped || delete-rollout.Omitted) && (delete-assess.Succeeded || delete-assess.Failed || delete-assess.Errored || delete-assess.Skipped || delete-assess.Omitted)',
              name: 'record-final-state',
              template: 'finalize',
            },
          ],
        },
        name: 'cleanup',
      },
      {
        name: 'delete-rollout',
        resource: {
          action: 'delete',
          flags: [
            '--ignore-not-found=true',
            '--cascade=foreground',
            '--wait=true',
            '--timeout=10m',
          ],
          manifest: jobReference.manifest('rollout'),
        },
      },
      {
        name: 'delete-assess',
        resource: {
          action: 'delete',
          flags: [
            '--ignore-not-found=true',
            '--cascade=foreground',
            '--wait=true',
            '--timeout=10m',
          ],
          manifest: jobReference.manifest('assess'),
        },
      },
      {
        name: 'finalize',
        podSpecPatch: podSpecPatch,
        container: {
          command: ['/app/.venv/bin/agr-finalize'],
          args: [
            '--workflow-uid',
            '{{workflow.uid}}',
            '--workflow-status',
            '{{workflow.status}}',
          ],
          env: [
            {
              name: 'WORKER_CONTROLLER_ID',
              value: 'agr-planner',
            },
            {
              name: 'SERVICE_ENDPOINT',
              value: 'http://agr-server.agr.svc.cluster.local:8080',
            },
            {
              name: 'SERVICE_GATEWAY_TOKEN',
              valueFrom: {
                secretKeyRef: {
                  key: 'SERVICE_GATEWAY_TOKEN',
                  name: 'agr-learning-token',
                },
              },
            },
            {
              name: 'AGR_WORKFLOW_UID',
              value: '{{workflow.uid}}',
            },
          ],
          image: 'ghcr.io/walnuts1018/agr-training:0.1.45@sha256:c2cd3c27105d65c1235f84805cfb6d14c7836bde228fe1a6e329f09eed589009',
          resources: {
            limits: {
              cpu: '500m',
              'ephemeral-storage': '1Gi',
              memory: '1Gi',
            },
            requests: {
              cpu: '100m',
              'ephemeral-storage': '128Mi',
              memory: '128Mi',
            },
          },
          securityContext: stagePod.securityContext,
          volumeMounts: [{ name: 'tmp', mountPath: '/tmp' }],
        },
        serviceAccountName: 'agr-planner',
        volumes: [{ name: 'tmp', emptyDir: { sizeLimit: '1Gi' } }],
      },
      {
        inputs: {
          parameters: [
            { name: 'trigger' },
            { name: 'retry-generation-id' },
          ],
        },
        name: 'create-attempt',
        outputs: {
          parameters: [
            {
              globalName: 'generation-id',
              name: 'generation-id',
              valueFrom: {
                path: '/tmp/create-attempt-output/generation-id',
              },
            },
            {
              name: 'generation-number',
              valueFrom: {
                path: '/tmp/create-attempt-output/generation-number',
              },
            },
            {
              globalName: 'attempt-id',
              name: 'attempt-id',
              valueFrom: {
                path: '/tmp/create-attempt-output/attempt-id',
              },
            },
            {
              name: 'skipped',
              valueFrom: {
                path: '/tmp/create-attempt-output/skipped',
              },
            },
          ],
        },
        podSpecPatch: podSpecPatch,
        container: {
          command: ['/app/.venv/bin/agr-create-attempt'],
          args: ['--argo-output-dir', '/tmp/create-attempt-output'],
          env: stagePod.s3Env('agr-planner', 'agr-planner', [
            {
              name: 'AWS_ENDPOINT_URL_S3',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
            },
            {
              name: 'AWS_ENDPOINT_URL_STS',
              value: 'https://seaweedfs.local.walnuts.dev',
            },
            {
              name: 'AWS_ROLE_ARN',
              value: 'arn:aws:iam::role/agr-planner',
            },
            {
              name: 'AWS_WEB_IDENTITY_TOKEN_FILE',
              value: '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token',
            },
            {
              name: 'AWS_REGION',
              value: 'us-east-1',
            },
            {
              name: 'WORKER_S3_BUCKET',
              value: 'agr-ai',
            },
            {
              name: 'WORKER_S3_PREFIX',
              value: 'worker-runs',
            },
            {
              name: 'WORKER_CONTROLLER_ID',
              value: 'agr-planner',
            },
            {
              name: 'SERVICE_ENDPOINT',
              value: 'http://agr-server.agr.svc.cluster.local:8080',
            },
            {
              name: 'SERVICE_GATEWAY_TOKEN',
              valueFrom: {
                secretKeyRef: {
                  key: 'SERVICE_GATEWAY_TOKEN',
                  name: 'agr-learning-token',
                },
              },
            },
            {
              name: 'AGR_TRAINING_IMAGE_REFERENCE',
              value: 'ghcr.io/walnuts1018/agr-training:0.1.45@sha256:c2cd3c27105d65c1235f84805cfb6d14c7836bde228fe1a6e329f09eed589009',
            },
            {
              name: 'AGR_WORKFLOW_UID',
              value: '{{workflow.uid}}',
            },
            {
              name: 'AGR_WORKFLOW_TRIGGER',
              value: '{{inputs.parameters.trigger}}',
            },
            {
              name: 'AGR_WORKFLOW_RETRY_GENERATION_ID',
              value: '{{inputs.parameters.retry-generation-id}}',
            },
          ]),
          image: 'ghcr.io/walnuts1018/agr-training:0.1.45@sha256:c2cd3c27105d65c1235f84805cfb6d14c7836bde228fe1a6e329f09eed589009',
          resources: {
            limits: {
              cpu: '500m',
              'ephemeral-storage': '1Gi',
              memory: '1Gi',
            },
            requests: {
              cpu: '100m',
              'ephemeral-storage': '128Mi',
              memory: '128Mi',
            },
          },
          securityContext: stagePod.securityContext,
          volumeMounts: stagePod.volumeMounts,
        },
        serviceAccountName: 'agr-planner',
        volumes: stagePod.volumes('1Gi'),
      },
    ],
    ttlStrategy: {
      secondsAfterCompletion: 604800,
    },
  },
}
