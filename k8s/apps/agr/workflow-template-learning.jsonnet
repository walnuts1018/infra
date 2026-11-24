local podSpecPatch = std.manifestJsonEx(import '_workflow_templates/pod-spec-patch.libsonnet', '', '', ':');
local stagePod = import '_workflow_templates/stage-pod.libsonnet';
local trainingImage = 'ghcr.io/walnuts1018/agr-training:0.1.59@sha256:3c8e65e3e394d8b651d857665dab2da64a269c0007ecc37680b71ca7fc50297e';
local workerImage = 'ghcr.io/walnuts1018/agr-worker:0.1.59@sha256:f5724e046732745fdfc38f4e49d071c8f0ffc27da15685052e0a335637646655';
local workerRetryStrategy = {
  limit: '5',
  retryPolicy: 'Always',
  expression: 'lastRetry.status == "Error" || asInt(lastRetry.exitCode) == 75',
  backoff: {
    duration: '10s',
    factor: 2,
    maxDuration: '5m',
  },
};
local s3Env(role, controllerId, extra=[]) =
  stagePod.s3Env(role, controllerId, [
    { name: 'AWS_ENDPOINT_URL_S3', value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333' },
    { name: 'AWS_ENDPOINT_URL_STS', value: 'https://seaweedfs.local.walnuts.dev' },
    { name: 'AWS_ROLE_ARN', value: 'arn:aws:iam::role/' + role },
    { name: 'AWS_WEB_IDENTITY_TOKEN_FILE', value: '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token' },
    { name: 'AWS_REGION', value: 'us-east-1' },
    { name: 'WORKER_S3_BUCKET', value: 'agr-ai' },
    { name: 'WORKER_S3_PREFIX', value: 'worker-runs' },
    { name: 'WORKER_CONTROLLER_ID', value: controllerId },
    { name: 'AGR_WORKFLOW_UID', value: '{{workflow.uid}}' },
  ] + extra);
local workerResources = {
  requests: {
    cpu: '1',
    memory: '2Gi',
    'ephemeral-storage': '512Mi',
  },
  limits: {
    cpu: '1',
    memory: '4Gi',
    'ephemeral-storage': '3Gi',
  },
};
local verifyResources = {
  requests: {
    cpu: '100m',
    memory: '256Mi',
    'ephemeral-storage': '128Mi',
  },
  limits: {
    cpu: '500m',
    memory: '1Gi',
    'ephemeral-storage': '1Gi',
  },
};
local evaluationLookTasks = std.flattenArrays([
  [
    {
      name: 'look-' + i,
      template: 'evaluation-unit',
      withSequence: {
        start: '0',
        count: '{{inputs.parameters.look-' + i + '-unit-count}}',
      },
      arguments: {
        parameters: [
          { name: 'unit-index', value: '{{item}}' },
          { name: 'generation-id', value: '{{inputs.parameters.generation-id}}' },
          { name: 'plan-uri', value: '{{inputs.parameters.plan-uri}}' },
          { name: 'plan-sha256', value: '{{inputs.parameters.plan-sha256}}' },
          { name: 'look-index', value: std.toString(i) },
        ],
      },
    } + (if i == 1 then {} else {
           depends: 'verify-look-' + (i - 1) + '.Succeeded',
         }) + {
      when: '{{inputs.parameters.look-' + i + '-unit-count}} > 0'
            + (if i == 1 then '' else ' && {{tasks.verify-look-' + (i - 1) + '.outputs.parameters.rejected}} == false'),
    },
    {
      name: 'verify-look-' + i,
      template: 'verify-evaluation-look',
      depends: 'look-' + i + '.Succeeded',
      arguments: {
        parameters: [
          { name: 'generation-id', value: '{{inputs.parameters.generation-id}}' },
          { name: 'plan-uri', value: '{{inputs.parameters.plan-uri}}' },
          { name: 'plan-sha256', value: '{{inputs.parameters.plan-sha256}}' },
          { name: 'stage', value: 'evaluation' },
          { name: 'look-index', value: std.toString(i) },
          { name: 'unit-count', value: '{{inputs.parameters.look-' + i + '-unit-count}}' },
        ],
      },
    },
  ]
  for i in std.range(1, 4)
]);
local lookRejectedParameter(i) = '{{tasks.evaluation.outputs.parameters.look-' + std.toString(i) + '-rejected}}';
local allLooksCompleted = std.join(' && ', [
  lookRejectedParameter(i) + ' == false'
  for i in std.range(1, 4)
]);
local anyLookRejected = std.join(' || ', [
  lookRejectedParameter(i) + ' == true'
  for i in std.range(1, 4)
]);
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
    onExit: 'finalize',
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
        name: 'learning',
        dag: {
          tasks: [
            {
              name: 'create-attempt',
              template: 'create-attempt',
              arguments: {
                parameters: [
                  { name: 'trigger', value: '{{workflow.parameters.trigger}}' },
                  { name: 'retry-generation-id', value: '{{workflow.parameters.retry-generation-id}}' },
                ],
              },
            },
            {
              name: 'plan',
              template: 'plan',
              depends: 'create-attempt.Succeeded',
              when: '{{tasks.create-attempt.outputs.parameters.skipped}} == false',
              arguments: {
                parameters: [{ name: 'generation-id', value: '{{tasks.create-attempt.outputs.parameters.generation-id}}' }],
              },
            },
            {
              name: 'rollout',
              template: 'rollout',
              depends: 'plan.Succeeded',
              arguments: {
                parameters: [
                  { name: 'generation-id', value: '{{tasks.plan.outputs.parameters.generation-id}}' },
                  { name: 'plan-uri', value: '{{tasks.plan.outputs.parameters.plan-uri}}' },
                  { name: 'plan-sha256', value: '{{tasks.plan.outputs.parameters.plan-sha256}}' },
                  { name: 'unit-count', value: '{{tasks.plan.outputs.parameters.rollout-unit-count}}' },
                ],
              },
            },
            {
              name: 'verify-rollout',
              template: 'verify-rollout',
              depends: 'rollout.Succeeded',
              arguments: {
                parameters: [
                  { name: 'generation-id', value: '{{tasks.plan.outputs.parameters.generation-id}}' },
                  { name: 'plan-uri', value: '{{tasks.plan.outputs.parameters.plan-uri}}' },
                  { name: 'plan-sha256', value: '{{tasks.plan.outputs.parameters.plan-sha256}}' },
                  { name: 'stage', value: 'rollout' },
                  { name: 'look-index', value: '0' },
                  { name: 'unit-count', value: '{{tasks.plan.outputs.parameters.rollout-unit-count}}' },
                ],
              },
            },
            {
              name: 'dataset',
              template: 'dataset',
              depends: 'verify-rollout.Succeeded',
              arguments: {
                parameters: [
                  { name: 'generation-id', value: '{{tasks.plan.outputs.parameters.generation-id}}' },
                  { name: 'plan-uri', value: '{{tasks.plan.outputs.parameters.plan-uri}}' },
                  { name: 'plan-sha256', value: '{{tasks.plan.outputs.parameters.plan-sha256}}' },
                ],
              },
            },
            {
              name: 'train',
              template: 'train',
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
            },
            {
              name: 'validate',
              template: 'validate',
              depends: 'train.Succeeded',
              arguments: {
                parameters: [
                  { name: 'generation-id', value: '{{tasks.plan.outputs.parameters.generation-id}}' },
                  { name: 'plan-uri', value: '{{tasks.plan.outputs.parameters.plan-uri}}' },
                ],
              },
            },
            {
              name: 'evaluation',
              template: 'evaluation',
              depends: 'validate.Succeeded',
              arguments: {
                parameters: [
                  { name: 'generation-id', value: '{{tasks.plan.outputs.parameters.generation-id}}' },
                  { name: 'plan-uri', value: '{{tasks.plan.outputs.parameters.plan-uri}}' },
                  { name: 'plan-sha256', value: '{{tasks.plan.outputs.parameters.plan-sha256}}' },
                  { name: 'look-1-unit-count', value: '{{tasks.plan.outputs.parameters.evaluation-look-1-unit-count}}' },
                  { name: 'look-2-unit-count', value: '{{tasks.plan.outputs.parameters.evaluation-look-2-unit-count}}' },
                  { name: 'look-3-unit-count', value: '{{tasks.plan.outputs.parameters.evaluation-look-3-unit-count}}' },
                  { name: 'look-4-unit-count', value: '{{tasks.plan.outputs.parameters.evaluation-look-4-unit-count}}' },
                ],
              },
            },
            {
              name: 'aggregate',
              template: 'aggregate',
              depends: 'evaluation.Succeeded',
              when: allLooksCompleted,
              arguments: {
                parameters: [
                  { name: 'generation-id', value: '{{tasks.plan.outputs.parameters.generation-id}}' },
                  { name: 'plan-uri', value: '{{tasks.plan.outputs.parameters.plan-uri}}' },
                  { name: 'plan-sha256', value: '{{tasks.plan.outputs.parameters.plan-sha256}}' },
                ],
              },
            },
            {
              name: 'record-rejection',
              template: 'record-rejection',
              depends: 'evaluation.Succeeded',
              when: anyLookRejected,
              arguments: {
                parameters: [
                  { name: 'generation-id', value: '{{tasks.plan.outputs.parameters.generation-id}}' },
                  { name: 'plan-uri', value: '{{tasks.plan.outputs.parameters.plan-uri}}' },
                  { name: 'plan-sha256', value: '{{tasks.plan.outputs.parameters.plan-sha256}}' },
                ] + [
                  {
                    name: 'look-' + std.toString(i) + '-rejected',
                    value: lookRejectedParameter(i),
                  }
                  for i in std.range(1, 4)
                ],
              },
            },
            {
              name: 'decide',
              template: 'decide',
              depends: 'evaluation.Succeeded && aggregate.Succeeded',
              when: allLooksCompleted,
              arguments: {
                parameters: [
                  { name: 'generation-id', value: '{{tasks.plan.outputs.parameters.generation-id}}' },
                  { name: 'plan-uri', value: '{{tasks.plan.outputs.parameters.plan-uri}}' },
                  { name: 'report-uri', value: '{{tasks.aggregate.outputs.parameters.report-uri}}' },
                ],
              },
            },
            {
              name: 'publish',
              template: 'publish',
              depends: 'decide.Succeeded',
              when: '{{tasks.decide.outputs.parameters.promote}} == true',
              arguments: {
                parameters: [
                  { name: 'generation-id', value: '{{tasks.plan.outputs.parameters.generation-id}}' },
                  { name: 'plan-uri', value: '{{tasks.plan.outputs.parameters.plan-uri}}' },
                  { name: 'report-uri', value: '{{tasks.aggregate.outputs.parameters.report-uri}}' },
                  { name: 'model-id', value: '{{tasks.train.outputs.parameters.model-id}}' },
                ],
              },
            },
            {
              name: 'verify',
              template: 'verify',
              depends: 'publish.Succeeded',
              arguments: {
                parameters: [
                  { name: 'generation-id', value: '{{tasks.plan.outputs.parameters.generation-id}}' },
                  { name: 'plan-uri', value: '{{tasks.plan.outputs.parameters.plan-uri}}' },
                ],
              },
            },
          ],
        },
      },
      {
        name: 'create-attempt',
        inputs: {
          parameters: [
            { name: 'trigger' },
            { name: 'retry-generation-id' },
          ],
        },
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
          env: s3Env('agr-planner', 'agr-planner', [
            { name: 'SERVICE_ENDPOINT', value: 'http://agr-server.agr.svc.cluster.local:8080' },
            {
              name: 'SERVICE_GATEWAY_TOKEN',
              valueFrom: {
                secretKeyRef: {
                  key: 'SERVICE_GATEWAY_TOKEN',
                  name: 'agr-learning-token',
                },
              },
            },
            { name: 'AGR_TRAINING_IMAGE_REFERENCE', value: trainingImage },
            { name: 'AGR_WORKFLOW_TRIGGER', value: '{{inputs.parameters.trigger}}' },
            { name: 'AGR_WORKFLOW_RETRY_GENERATION_ID', value: '{{inputs.parameters.retry-generation-id}}' },
          ]),
          image: trainingImage,
          resources: {
            limits: {
              cpu: '500m',
              'ephemeral-storage': '1Gi',
              memory: '1Gi',
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
        name: 'plan',
        inputs: {
          parameters: [{ name: 'generation-id' }],
        },
        outputs: {
          parameters: [
            {
              name: 'generation-id',
              valueFrom: {
                path: '/tmp/plan-output/generation-id',
              },
            },
            {
              name: 'plan-uri',
              valueFrom: {
                path: '/tmp/plan-output/plan-uri',
              },
            },
            {
              name: 'plan-sha256',
              valueFrom: {
                path: '/tmp/plan-output/plan-sha256',
              },
            },
            {
              name: 'rollout-unit-count',
              valueFrom: {
                path: '/tmp/plan-output/rollout-unit-count',
              },
            },
            {
              name: 'evaluation-look-1-unit-count',
              valueFrom: {
                path: '/tmp/plan-output/evaluation-look-1-unit-count',
              },
            },
            {
              name: 'evaluation-look-2-unit-count',
              valueFrom: {
                path: '/tmp/plan-output/evaluation-look-2-unit-count',
              },
            },
            {
              name: 'evaluation-look-3-unit-count',
              valueFrom: {
                path: '/tmp/plan-output/evaluation-look-3-unit-count',
              },
            },
            {
              name: 'evaluation-look-4-unit-count',
              valueFrom: {
                path: '/tmp/plan-output/evaluation-look-4-unit-count',
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
          args: ['--argo-output-dir', '/tmp/plan-output'],
          env: s3Env('agr-planner', 'agr-planner', [
            { name: 'SERVICE_ENDPOINT', value: 'http://agr-server.agr.svc.cluster.local:8080' },
            {
              name: 'SERVICE_GATEWAY_TOKEN',
              valueFrom: {
                secretKeyRef: {
                  key: 'SERVICE_GATEWAY_TOKEN',
                  name: 'agr-learning-token',
                },
              },
            },
            { name: 'AGR_TRAINING_IMAGE_REFERENCE', value: trainingImage },
            { name: 'AGR_WORKFLOW_GENERATION_ID', value: '{{inputs.parameters.generation-id}}' },
          ]),
          image: trainingImage,
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
        name: 'rollout',
        inputs: {
          parameters: [
            { name: 'generation-id' },
            { name: 'plan-uri' },
            { name: 'plan-sha256' },
            { name: 'unit-count' },
          ],
        },
        parallelism: 2,
        dag: {
          tasks: [
            {
              name: 'unit',
              template: 'rollout-unit',
              withSequence: {
                start: '0',
                count: '{{inputs.parameters.unit-count}}',
              },
              arguments: {
                parameters: [
                  { name: 'unit-index', value: '{{item}}' },
                  { name: 'generation-id', value: '{{inputs.parameters.generation-id}}' },
                  { name: 'plan-uri', value: '{{inputs.parameters.plan-uri}}' },
                  { name: 'plan-sha256', value: '{{inputs.parameters.plan-sha256}}' },
                ],
              },
            },
          ],
        },
      },
      {
        name: 'rollout-unit',
        inputs: {
          parameters: [
            { name: 'unit-index' },
            { name: 'generation-id' },
            { name: 'plan-uri' },
            { name: 'plan-sha256' },
          ],
        },
        retryStrategy: workerRetryStrategy,
        podSpecPatch: podSpecPatch,
        serviceAccountName: 'agr-actor',
        volumes: stagePod.volumes('2Gi'),
        container: {
          image: workerImage,
          command: ['worker'],
          args: [
            'work-unit',
            '--generation-id',
            '{{inputs.parameters.generation-id}}',
            '--plan-uri',
            '{{inputs.parameters.plan-uri}}',
            '--plan-sha256',
            '{{inputs.parameters.plan-sha256}}',
            '--stage',
            'rollout',
            '--look-index',
            '0',
            '--unit-index',
            '{{inputs.parameters.unit-index}}',
          ],
          env: s3Env('agr-actor', 'agr-actor', [
            { name: 'AGR_WORKER_IMAGE_REFERENCE', value: workerImage },
            { name: 'WORKER_S3_ENDPOINT', value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333' },
            { name: 'OMP_NUM_THREADS', value: '1' },
          ]),
          resources: workerResources,
          securityContext: stagePod.securityContext,
          volumeMounts: stagePod.volumeMounts,
        },
      },
      {
        name: 'verify-rollout',
        inputs: {
          parameters: [
            { name: 'generation-id' },
            { name: 'plan-uri' },
            { name: 'plan-sha256' },
            { name: 'stage' },
            { name: 'look-index' },
            { name: 'unit-count' },
          ],
        },
        podSpecPatch: podSpecPatch,
        serviceAccountName: 'agr-dataset',
        volumes: stagePod.volumes('1Gi'),
        container: {
          image: trainingImage,
          command: ['/app/.venv/bin/agr-verify-rollout'],
          args: [
            '--generation-id',
            '{{inputs.parameters.generation-id}}',
            '--plan-uri',
            '{{inputs.parameters.plan-uri}}',
            '--plan-sha256',
            '{{inputs.parameters.plan-sha256}}',
            '--stage',
            '{{inputs.parameters.stage}}',
            '--look-index',
            '{{inputs.parameters.look-index}}',
            '--unit-count',
            '{{inputs.parameters.unit-count}}',
          ],
          env: s3Env('agr-dataset', 'agr-dataset', [
            { name: 'AGR_TRAINING_IMAGE_REFERENCE', value: trainingImage },
            { name: 'AGR_WORKFLOW_GENERATION_ID', value: '{{inputs.parameters.generation-id}}' },
            { name: 'AGR_WORKFLOW_PLAN_URI', value: '{{inputs.parameters.plan-uri}}' },
            { name: 'AGR_WORKFLOW_PLAN_SHA256', value: '{{inputs.parameters.plan-sha256}}' },
          ]),
          resources: verifyResources,
          securityContext: stagePod.securityContext,
          volumeMounts: stagePod.volumeMounts,
        },
      },
      {
        name: 'dataset',
        inputs: {
          parameters: [
            { name: 'generation-id' },
            { name: 'plan-uri' },
            { name: 'plan-sha256' },
          ],
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
        podSpecPatch: podSpecPatch,
        serviceAccountName: 'agr-dataset',
        volumes: stagePod.volumes('4Gi'),
        container: {
          image: trainingImage,
          command: ['/app/.venv/bin/agr-build-dataset'],
          args: ['--argo-output-dir', '/tmp/dataset-output'],
          env: s3Env('agr-dataset', 'agr-dataset', [
            { name: 'OMP_NUM_THREADS', value: '1' },
            { name: 'MKL_NUM_THREADS', value: '1' },
            { name: 'AGR_TRAINING_IMAGE_REFERENCE', value: trainingImage },
            { name: 'AGR_WORKFLOW_GENERATION_ID', value: '{{inputs.parameters.generation-id}}' },
            { name: 'AGR_WORKFLOW_PLAN_URI', value: '{{inputs.parameters.plan-uri}}' },
            { name: 'AGR_WORKFLOW_PLAN_SHA256', value: '{{inputs.parameters.plan-sha256}}' },
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
      },
      {
        name: 'train',
        inputs: {
          parameters: [
            { name: 'generation-id' },
            { name: 'plan-uri' },
            { name: 'dataset-uri' },
            { name: 'learner-artifact-uri' },
            { name: 'learner-sha256' },
          ],
        },
        podSpecPatch: podSpecPatch,
        serviceAccountName: 'agr-trainer',
        volumes: stagePod.volumes('10Gi'),
        container: {
          image: trainingImage,
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
          env: s3Env('agr-trainer', 'agr-trainer', [
            { name: 'OMP_NUM_THREADS', value: '2' },
            { name: 'MKL_NUM_THREADS', value: '2' },
            { name: 'OPENBLAS_NUM_THREADS', value: '2' },
            { name: 'TORCH_NUM_THREADS', value: '2' },
            { name: 'AGR_TRAINING_IMAGE_REFERENCE', value: trainingImage },
            { name: 'AGR_WORKFLOW_GENERATION_ID', value: '{{inputs.parameters.generation-id}}' },
            { name: 'AGR_WORKFLOW_PLAN_URI', value: '{{inputs.parameters.plan-uri}}' },
            { name: 'AGR_WORKFLOW_INPUT_URI', value: '{{inputs.parameters.dataset-uri}}' },
            { name: 'AGR_WORKFLOW_OUTPUT_URI', value: 's3://agr-ai/worker-runs/models/candidates/{{inputs.parameters.generation-id}}' },
            { name: 'AGR_WORKFLOW_LEARNER_URI', value: '{{inputs.parameters.learner-artifact-uri}}' },
            { name: 'AGR_WORKFLOW_LEARNER_SHA256', value: '{{inputs.parameters.learner-sha256}}' },
            { name: 'AGR_WORKFLOW_BEHAVIOR_POLICY_SHA256', value: '{{inputs.parameters.learner-sha256}}' },
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
        name: 'validate',
        inputs: {
          parameters: [
            { name: 'generation-id' },
            { name: 'plan-uri' },
          ],
        },
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
          env: s3Env('agr-validator', 'agr-validator', [
            { name: 'AGR_TRAINING_IMAGE_REFERENCE', value: trainingImage },
            { name: 'AGR_WORKFLOW_GENERATION_ID', value: '{{inputs.parameters.generation-id}}' },
            { name: 'AGR_WORKFLOW_PLAN_URI', value: '{{inputs.parameters.plan-uri}}' },
          ]),
          image: trainingImage,
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
        name: 'evaluation',
        inputs: {
          parameters: [
            { name: 'generation-id' },
            { name: 'plan-uri' },
            { name: 'plan-sha256' },
            { name: 'look-1-unit-count' },
            { name: 'look-2-unit-count' },
            { name: 'look-3-unit-count' },
            { name: 'look-4-unit-count' },
          ],
        },
        outputs: {
          parameters: [
            {
              name: 'look-' + std.toString(i) + '-rejected',
              valueFrom: {
                parameter: '{{tasks.verify-look-' + std.toString(i) + '.outputs.parameters.rejected}}',
                default: 'false',
              },
            }
            for i in std.range(1, 4)
          ],
        },
        parallelism: 2,
        dag: {
          tasks: evaluationLookTasks,
        },
      },
      {
        name: 'evaluation-unit',
        inputs: {
          parameters: [
            { name: 'unit-index' },
            { name: 'generation-id' },
            { name: 'plan-uri' },
            { name: 'plan-sha256' },
            { name: 'look-index' },
          ],
        },
        retryStrategy: workerRetryStrategy,
        podSpecPatch: podSpecPatch,
        serviceAccountName: 'agr-evaluator',
        volumes: stagePod.volumes('2Gi'),
        container: {
          image: workerImage,
          command: ['worker'],
          args: [
            'work-unit',
            '--generation-id',
            '{{inputs.parameters.generation-id}}',
            '--plan-uri',
            '{{inputs.parameters.plan-uri}}',
            '--plan-sha256',
            '{{inputs.parameters.plan-sha256}}',
            '--stage',
            'evaluation',
            '--look-index',
            '{{inputs.parameters.look-index}}',
            '--unit-index',
            '{{inputs.parameters.unit-index}}',
          ],
          env: s3Env('agr-evaluator', 'agr-evaluator', [
            { name: 'AGR_WORKER_IMAGE_REFERENCE', value: workerImage },
            { name: 'WORKER_S3_ENDPOINT', value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333' },
            { name: 'OMP_NUM_THREADS', value: '1' },
          ]),
          resources: workerResources,
          securityContext: stagePod.securityContext,
          volumeMounts: stagePod.volumeMounts,
        },
      },
      {
        name: 'verify-evaluation-look',
        inputs: {
          parameters: [
            { name: 'generation-id' },
            { name: 'plan-uri' },
            { name: 'plan-sha256' },
            { name: 'stage' },
            { name: 'look-index' },
            { name: 'unit-count' },
          ],
        },
        outputs: {
          parameters: [
            {
              name: 'rejected',
              valueFrom: {
                path: '/tmp/verify-output/rejected',
                default: 'false',
              },
            },
          ],
        },
        podSpecPatch: podSpecPatch,
        serviceAccountName: 'agr-evaluator',
        volumes: stagePod.volumes('1Gi'),
        container: {
          image: trainingImage,
          command: ['/app/.venv/bin/agr-verify-evaluation-look'],
          args: [
            '--generation-id',
            '{{inputs.parameters.generation-id}}',
            '--plan-uri',
            '{{inputs.parameters.plan-uri}}',
            '--plan-sha256',
            '{{inputs.parameters.plan-sha256}}',
            '--stage',
            '{{inputs.parameters.stage}}',
            '--look-index',
            '{{inputs.parameters.look-index}}',
            '--unit-count',
            '{{inputs.parameters.unit-count}}',
            '--argo-output-dir',
            '/tmp/verify-output',
          ],
          env: s3Env('agr-evaluator', 'agr-evaluator', [
            { name: 'AGR_TRAINING_IMAGE_REFERENCE', value: trainingImage },
            { name: 'AGR_WORKFLOW_GENERATION_ID', value: '{{inputs.parameters.generation-id}}' },
            { name: 'AGR_WORKFLOW_PLAN_URI', value: '{{inputs.parameters.plan-uri}}' },
            { name: 'AGR_WORKFLOW_PLAN_SHA256', value: '{{inputs.parameters.plan-sha256}}' },
          ]),
          resources: verifyResources,
          securityContext: stagePod.securityContext,
          volumeMounts: stagePod.volumeMounts,
        },
      },
      {
        name: 'aggregate',
        inputs: {
          parameters: [
            { name: 'generation-id' },
            { name: 'plan-uri' },
            { name: 'plan-sha256' },
          ],
        },
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
          env: s3Env('agr-evaluator', 'agr-evaluator', [
            { name: 'AGR_TRAINING_IMAGE_REFERENCE', value: trainingImage },
            { name: 'AGR_WORKFLOW_GENERATION_ID', value: '{{inputs.parameters.generation-id}}' },
            { name: 'AGR_WORKFLOW_PLAN_URI', value: '{{inputs.parameters.plan-uri}}' },
            { name: 'AGR_WORKFLOW_PLAN_SHA256', value: '{{inputs.parameters.plan-sha256}}' },
          ]),
          image: trainingImage,
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
        name: 'decide',
        inputs: {
          parameters: [
            { name: 'generation-id' },
            { name: 'plan-uri' },
            { name: 'report-uri' },
          ],
        },
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
          env: s3Env('agr-evaluator', 'agr-evaluator', [
            { name: 'AGR_TRAINING_IMAGE_REFERENCE', value: trainingImage },
            { name: 'AGR_WORKFLOW_GENERATION_ID', value: '{{inputs.parameters.generation-id}}' },
            { name: 'AGR_WORKFLOW_PLAN_URI', value: '{{inputs.parameters.plan-uri}}' },
            { name: 'AGR_EVALUATION_REPORT_URI', value: '{{inputs.parameters.report-uri}}' },
          ]),
          image: trainingImage,
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
        name: 'record-rejection',
        inputs: {
          parameters: [
            { name: 'generation-id' },
            { name: 'plan-uri' },
            { name: 'plan-sha256' },
            { name: 'look-1-rejected' },
            { name: 'look-2-rejected' },
            { name: 'look-3-rejected' },
            { name: 'look-4-rejected' },
          ],
        },
        outputs: {
          parameters: [
            {
              name: 'report-uri',
              valueFrom: {
                path: '/tmp/rejection-output/report-uri',
              },
            },
            {
              name: 'decision-uri',
              valueFrom: {
                path: '/tmp/rejection-output/decision-uri',
              },
            },
          ],
        },
        podSpecPatch: podSpecPatch,
        container: {
          command: ['/app/.venv/bin/agr-record-rejection'],
          args: [
            '--generation-id',
            '{{inputs.parameters.generation-id}}',
            '--plan-uri',
            '{{inputs.parameters.plan-uri}}',
            '--plan-sha256',
            '{{inputs.parameters.plan-sha256}}',
            '--argo-output-dir',
            '/tmp/rejection-output',
          ],
          env: s3Env('agr-evaluator', 'agr-evaluator', [
            { name: 'AGR_TRAINING_IMAGE_REFERENCE', value: trainingImage },
            { name: 'AGR_WORKFLOW_GENERATION_ID', value: '{{inputs.parameters.generation-id}}' },
            { name: 'AGR_WORKFLOW_PLAN_URI', value: '{{inputs.parameters.plan-uri}}' },
            { name: 'AGR_WORKFLOW_PLAN_SHA256', value: '{{inputs.parameters.plan-sha256}}' },
            { name: 'AGR_EVALUATION_LOOK_1_REJECTED', value: '{{inputs.parameters.look-1-rejected}}' },
            { name: 'AGR_EVALUATION_LOOK_2_REJECTED', value: '{{inputs.parameters.look-2-rejected}}' },
            { name: 'AGR_EVALUATION_LOOK_3_REJECTED', value: '{{inputs.parameters.look-3-rejected}}' },
            { name: 'AGR_EVALUATION_LOOK_4_REJECTED', value: '{{inputs.parameters.look-4-rejected}}' },
          ]),
          image: trainingImage,
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
          env: s3Env('agr-promoter', 'agr-promoter', [
            { name: 'AGR_TRAINING_IMAGE_REFERENCE', value: trainingImage },
            { name: 'AGR_EVALUATION_REPORT_URI', value: '{{inputs.parameters.report-uri}}' },
            { name: 'AGR_WORKFLOW_GENERATION_ID', value: '{{inputs.parameters.generation-id}}' },
            { name: 'AGR_WORKFLOW_PLAN_URI', value: '{{inputs.parameters.plan-uri}}' },
          ]),
          image: trainingImage,
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
          env: s3Env('agr-verify', 'agr-verify', [
            { name: 'AGR_TRAINING_IMAGE_REFERENCE', value: trainingImage },
            { name: 'AGR_WORKFLOW_GENERATION_ID', value: '{{inputs.parameters.generation-id}}' },
            { name: 'AGR_WORKFLOW_PLAN_URI', value: '{{inputs.parameters.plan-uri}}' },
            { name: 'AGR_SERVER_SERVICE_HEALTH_URL', value: 'http://agr-server.agr.svc.cluster.local:8081' },
          ]),
          image: trainingImage,
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
          image: trainingImage,
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
    ],
    ttlStrategy: {
      secondsAfterCompletion: 604800,
    },
  },
}
