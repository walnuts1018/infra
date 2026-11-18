local podSpecPatch = std.manifestJsonEx(import '_workflow_templates/pod-spec-patch.libsonnet', '', '', ':');
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
    synchronization: {
      mutexes: [{ name: 'agr-training' }],
    },
    templates: [
      {
        dag: {
          tasks: [
            {
              name: 'create-attempt',
              template: 'create-attempt',
            },
            {
              dependencies: [
                'create-attempt',
              ],
              name: 'plan',
              template: 'plan',
            },
            {
              dependencies: [
                'plan',
              ],
              name: 'rollout',
              template: 'rollout',
            },
            {
              dependencies: [
                'rollout',
              ],
              name: 'dataset',
              template: 'dataset',
            },
            {
              dependencies: [
                'dataset',
              ],
              name: 'train',
              template: 'train',
            },
            {
              dependencies: [
                'train',
              ],
              name: 'validate',
              template: 'validate',
            },
            {
              dependencies: [
                'validate',
              ],
              name: 'assess',
              template: 'assess',
            },
            {
              dependencies: [
                'assess',
              ],
              name: 'aggregate',
              template: 'aggregate',
            },
            {
              dependencies: [
                'aggregate',
              ],
              name: 'decide',
              template: 'decide',
            },
            {
              dependencies: [
                'decide',
              ],
              name: 'publish',
              template: 'publish',
              when: '{{tasks.decide.outputs.parameters.promote}} == true',
            },
            {
              dependencies: [
                'publish',
              ],
              name: 'verify',
              template: 'verify',
            },
          ],
        },
        name: 'learning',
      },
      {
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
        script: {
          command: [
            '/bin/sh',
            '-e',
          ],
          env: [
            {
              name: 'AGR_WORKFLOW_NAME',
              value: '{{workflow.name}}',
            },
            {
              name: 'AWS_ENDPOINT_URL_S3',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
            },
            {
              name: 'AWS_ENDPOINT_URL_STS',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
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
              value: 'ghcr.io/walnuts1018/agr-training:0.1.15@sha256:caba8be0b12864071e4958abdf1a768a022b2549947c4cd8b1c2bc4d2b25c09b',
            },
            {
              name: 'AGR_WORKFLOW_UID',
              value: '{{workflow.uid}}',
            },
            {
              name: 'AGR_WORKFLOW_OUTPUT_FILE',
              value: '/tmp/plan.json',
            },
            {
              name: 'AGR_WORKFLOW_GENERATION_ID',
              value: '{{tasks.create-attempt.outputs.parameters.generation-id}}',
            },
          ],
          image: 'ghcr.io/walnuts1018/agr-training:0.1.15@sha256:caba8be0b12864071e4958abdf1a768a022b2549947c4cd8b1c2bc4d2b25c09b',
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
          securityContext: {
            allowPrivilegeEscalation: false,
            capabilities: {
              drop: [
                'ALL',
              ],
            },
            readOnlyRootFilesystem: true,
            runAsGroup: 10001,
            runAsNonRoot: true,
            runAsUser: 10001,
          },
          source: importstr '_workflow_templates/plan.sh',
          volumeMounts: [
            {
              mountPath: '/etc/agr',
              name: 'learning-settings',
              readOnly: true,
            },
            {
              mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
              name: 'sts-token',
              readOnly: true,
            },
            {
              mountPath: '/tmp',
              name: 'tmp',
            },
          ],
        },
        serviceAccountName: 'agr-planner',
        volumes: [
          {
            configMap: {
              name: 'learning-settings',
            },
            name: 'learning-settings',
          },
          {
            name: 'sts-token',
            projected: {
              sources: [
                {
                  serviceAccountToken: {
                    audience: 'sts.seaweedfs.com',
                    expirationSeconds: 3600,
                    path: 'token',
                  },
                },
              ],
            },
          },
          {
            emptyDir: {
              sizeLimit: '1Gi',
            },
            name: 'tmp',
          },
        ],
      },
      {
        inputs: {
          parameters: [
            { name: 'generation-id', value: '{{tasks.plan.outputs.parameters.generation-id}}' },
            { name: 'config-sha256', value: '{{tasks.plan.outputs.parameters.config-sha256}}' },
            { name: 'plan-uri', value: '{{tasks.plan.outputs.parameters.plan-uri}}' },
            { name: 'shard-count', value: '{{tasks.plan.outputs.parameters.rollout-shards}}' },
            { name: 'actor-pods', value: '{{tasks.plan.outputs.parameters.actor-pods}}' },
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
            { name: 'wait-indexed-job', template: 'wait-rollout-indexed-job', dependencies: ['apply-job'] },
          ],
        },
      },
      {
        name: 'dataset',
        podSpecPatch: podSpecPatch,
        serviceAccountName: 'agr-dataset',
        volumes: [
          {
            configMap: {
              name: 'learning-settings',
            },
            name: 'learning-settings',
          },
          {
            name: 'sts-token',
            projected: {
              sources: [
                {
                  serviceAccountToken: {
                    audience: 'sts.seaweedfs.com',
                    expirationSeconds: 3600,
                    path: 'token',
                  },
                },
              ],
            },
          },
          {
            emptyDir: {
              sizeLimit: '4Gi',
            },
            name: 'tmp',
          },
        ],
        script: {
          image: 'ghcr.io/walnuts1018/agr-training:0.1.15@sha256:caba8be0b12864071e4958abdf1a768a022b2549947c4cd8b1c2bc4d2b25c09b',
          command: [
            '/bin/sh',
            '-e',
          ],
          source: importstr '_workflow_templates/dataset.sh',
          env: [
            {
              name: 'AWS_ENDPOINT_URL_S3',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
            },
            {
              name: 'AWS_ENDPOINT_URL_STS',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
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
              value: 'ghcr.io/walnuts1018/agr-training:0.1.15@sha256:caba8be0b12864071e4958abdf1a768a022b2549947c4cd8b1c2bc4d2b25c09b',
            },
            {
              name: 'AGR_WORKFLOW_UID',
              value: '{{workflow.uid}}',
            },
            {
              name: 'AGR_WORKFLOW_GENERATION_ID',
              value: '{{tasks.plan.outputs.parameters.generation-id}}',
            },
            {
              name: 'AGR_WORKFLOW_PLAN_URI',
              value: '{{tasks.plan.outputs.parameters.plan-uri}}',
            },
            {
              name: 'AGR_WORKFLOW_OUTPUT_FILE',
              value: '/tmp/dataset.json',
            },
          ],
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
          securityContext: {
            allowPrivilegeEscalation: false,
            capabilities: {
              drop: [
                'ALL',
              ],
            },
            readOnlyRootFilesystem: true,
            runAsGroup: 10001,
            runAsNonRoot: true,
            runAsUser: 10001,
          },
          volumeMounts: [
            {
              mountPath: '/etc/agr',
              name: 'learning-settings',
              readOnly: true,
            },
            {
              mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
              name: 'sts-token',
              readOnly: true,
            },
            {
              mountPath: '/tmp',
              name: 'tmp',
            },
          ],
        },
        outputs: {
          parameters: [
            {
              name: 'dataset-uri',
              valueFrom: {
                path: '/tmp/dataset-uri',
              },
            },
          ],
        },
      },
      {
        name: 'train',
        podSpecPatch: podSpecPatch,
        serviceAccountName: 'agr-trainer',
        volumes: [
          {
            configMap: {
              name: 'learning-settings',
            },
            name: 'learning-settings',
          },
          {
            name: 'sts-token',
            projected: {
              sources: [
                {
                  serviceAccountToken: {
                    audience: 'sts.seaweedfs.com',
                    expirationSeconds: 3600,
                    path: 'token',
                  },
                },
              ],
            },
          },
          {
            emptyDir: {
              sizeLimit: '10Gi',
            },
            name: 'tmp',
          },
        ],
        script: {
          image: 'ghcr.io/walnuts1018/agr-training:0.1.15@sha256:caba8be0b12864071e4958abdf1a768a022b2549947c4cd8b1c2bc4d2b25c09b',
          command: [
            '/bin/sh',
            '-e',
          ],
          source: importstr '_workflow_templates/train.sh',
          env: [
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
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
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
              value: 'ghcr.io/walnuts1018/agr-training:0.1.15@sha256:caba8be0b12864071e4958abdf1a768a022b2549947c4cd8b1c2bc4d2b25c09b',
            },
            {
              name: 'AGR_WORKFLOW_UID',
              value: '{{workflow.uid}}',
            },
            {
              name: 'AGR_WORKFLOW_GENERATION_ID',
              value: '{{tasks.plan.outputs.parameters.generation-id}}',
            },
            {
              name: 'AGR_WORKFLOW_PLAN_URI',
              value: '{{tasks.plan.outputs.parameters.plan-uri}}',
            },
            {
              name: 'AGR_WORKFLOW_INPUT_URI',
              value: '{{tasks.dataset.outputs.parameters.dataset-uri}}',
            },
            {
              name: 'AGR_WORKFLOW_OUTPUT_URI',
              value: 's3://agr-ai/worker-runs/models/candidates/{{tasks.plan.outputs.parameters.generation-id}}',
            },
            {
              name: 'AGR_WORKFLOW_LEARNER_URI',
              value: '{{tasks.plan.outputs.parameters.learner-artifact-uri}}',
            },
            {
              name: 'AGR_WORKFLOW_LEARNER_SHA256',
              value: '{{tasks.plan.outputs.parameters.learner-sha256}}',
            },
            {
              name: 'AGR_WORKFLOW_BEHAVIOR_POLICY_SHA256',
              value: '{{tasks.plan.outputs.parameters.learner-sha256}}',
            },
            {
              name: 'AGR_WORKFLOW_OUTPUT_FILE',
              value: '/tmp/train.json',
            },
          ],
          resources: {
            limits: {
              cpu: '1900m',
              'ephemeral-storage': '10Gi',
              memory: '6016Mi',
            },
            requests: {
              cpu: '900m',
              'ephemeral-storage': '2Gi',
              memory: '1984Mi',
            },
          },
          securityContext: {
            allowPrivilegeEscalation: false,
            capabilities: {
              drop: [
                'ALL',
              ],
            },
            readOnlyRootFilesystem: true,
            runAsGroup: 10001,
            runAsNonRoot: true,
            runAsUser: 10001,
          },
          volumeMounts: [
            {
              mountPath: '/etc/agr',
              name: 'learning-settings',
              readOnly: true,
            },
            {
              mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
              name: 'sts-token',
              readOnly: true,
            },
            {
              mountPath: '/tmp',
              name: 'tmp',
            },
          ],
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
        script: {
          command: [
            '/bin/sh',
            '-e',
          ],
          env: [
            {
              name: 'AWS_ENDPOINT_URL_S3',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
            },
            {
              name: 'AWS_ENDPOINT_URL_STS',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
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
              name: 'AGR_WORKFLOW_OUTPUT_FILE',
              value: '/tmp/validation.json',
            },
            {
              name: 'AGR_TRAINING_IMAGE_REFERENCE',
              value: 'ghcr.io/walnuts1018/agr-training:0.1.15@sha256:caba8be0b12864071e4958abdf1a768a022b2549947c4cd8b1c2bc4d2b25c09b',
            },
            {
              name: 'AGR_WORKFLOW_UID',
              value: '{{workflow.uid}}',
            },
            {
              name: 'AGR_WORKFLOW_GENERATION_ID',
              value: '{{tasks.plan.outputs.parameters.generation-id}}',
            },
            {
              name: 'AGR_WORKFLOW_PLAN_URI',
              value: '{{tasks.plan.outputs.parameters.plan-uri}}',
            },
          ],
          image: 'ghcr.io/walnuts1018/agr-training:0.1.15@sha256:caba8be0b12864071e4958abdf1a768a022b2549947c4cd8b1c2bc4d2b25c09b',
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
          securityContext: {
            allowPrivilegeEscalation: false,
            capabilities: {
              drop: [
                'ALL',
              ],
            },
            readOnlyRootFilesystem: true,
            runAsGroup: 10001,
            runAsNonRoot: true,
            runAsUser: 10001,
          },
          source: importstr '_workflow_templates/validate.sh',
          volumeMounts: [
            {
              mountPath: '/etc/agr',
              name: 'learning-settings',
              readOnly: true,
            },
            {
              mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
              name: 'sts-token',
              readOnly: true,
            },
            {
              mountPath: '/tmp',
              name: 'tmp',
            },
          ],
        },
        serviceAccountName: 'agr-validator',
        volumes: [
          {
            configMap: {
              name: 'learning-settings',
            },
            name: 'learning-settings',
          },
          {
            name: 'sts-token',
            projected: {
              sources: [
                {
                  serviceAccountToken: {
                    audience: 'sts.seaweedfs.com',
                    expirationSeconds: 3600,
                    path: 'token',
                  },
                },
              ],
            },
          },
          {
            emptyDir: {
              sizeLimit: '2Gi',
            },
            name: 'tmp',
          },
        ],
      },
      {
        inputs: {
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
            { name: 'wait-indexed-job', template: 'wait-assess-indexed-job', dependencies: ['apply-job'] },
          ],
        },
      },
      {
        name: 'aggregate',
        outputs: {
          parameters: [
            {
              name: 'report-uri',
              valueFrom: {
                path: '/tmp/report-uri',
              },
            },
          ],
        },
        podSpecPatch: podSpecPatch,
        script: {
          command: [
            '/bin/sh',
            '-e',
          ],
          env: [
            {
              name: 'AWS_ENDPOINT_URL_S3',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
            },
            {
              name: 'AWS_ENDPOINT_URL_STS',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
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
              value: 'ghcr.io/walnuts1018/agr-training:0.1.15@sha256:caba8be0b12864071e4958abdf1a768a022b2549947c4cd8b1c2bc4d2b25c09b',
            },
            {
              name: 'AGR_WORKFLOW_UID',
              value: '{{workflow.uid}}',
            },
            {
              name: 'AGR_WORKFLOW_GENERATION_ID',
              value: '{{tasks.plan.outputs.parameters.generation-id}}',
            },
            {
              name: 'AGR_WORKFLOW_PLAN_URI',
              value: '{{tasks.plan.outputs.parameters.plan-uri}}',
            },
            {
              name: 'AGR_WORKFLOW_OUTPUT_FILE',
              value: '/tmp/aggregate.json',
            },
          ],
          image: 'ghcr.io/walnuts1018/agr-training:0.1.15@sha256:caba8be0b12864071e4958abdf1a768a022b2549947c4cd8b1c2bc4d2b25c09b',
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
          securityContext: {
            allowPrivilegeEscalation: false,
            capabilities: {
              drop: [
                'ALL',
              ],
            },
            readOnlyRootFilesystem: true,
            runAsGroup: 10001,
            runAsNonRoot: true,
            runAsUser: 10001,
          },
          source: importstr '_workflow_templates/aggregate.sh',
          volumeMounts: [
            {
              mountPath: '/etc/agr',
              name: 'learning-settings',
              readOnly: true,
            },
            {
              mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
              name: 'sts-token',
              readOnly: true,
            },
            {
              mountPath: '/tmp',
              name: 'tmp',
            },
          ],
        },
        serviceAccountName: 'agr-evaluator',
        volumes: [
          {
            configMap: {
              name: 'learning-settings',
            },
            name: 'learning-settings',
          },
          {
            name: 'sts-token',
            projected: {
              sources: [
                {
                  serviceAccountToken: {
                    audience: 'sts.seaweedfs.com',
                    expirationSeconds: 3600,
                    path: 'token',
                  },
                },
              ],
            },
          },
          {
            emptyDir: {
              sizeLimit: '2Gi',
            },
            name: 'tmp',
          },
        ],
      },
      {
        inputs: {
          parameters: [
            {
              name: 'report-uri',
              value: '{{tasks.aggregate.outputs.parameters.report-uri}}',
            },
          ],
        },
        name: 'decide',
        outputs: {
          parameters: [
            {
              globalName: 'promote',
              name: 'promote',
              valueFrom: {
                path: '/tmp/promote',
              },
            },
          ],
        },
        podSpecPatch: podSpecPatch,
        script: {
          command: [
            '/bin/sh',
            '-e',
          ],
          env: [
            {
              name: 'AWS_ENDPOINT_URL_S3',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
            },
            {
              name: 'AWS_ENDPOINT_URL_STS',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
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
              value: 'ghcr.io/walnuts1018/agr-training:0.1.15@sha256:caba8be0b12864071e4958abdf1a768a022b2549947c4cd8b1c2bc4d2b25c09b',
            },
            {
              name: 'AGR_WORKFLOW_UID',
              value: '{{workflow.uid}}',
            },
            {
              name: 'AGR_WORKFLOW_GENERATION_ID',
              value: '{{tasks.plan.outputs.parameters.generation-id}}',
            },
            {
              name: 'AGR_WORKFLOW_PLAN_URI',
              value: '{{tasks.plan.outputs.parameters.plan-uri}}',
            },
            {
              name: 'AGR_EVALUATION_REPORT_URI',
              value: '{{inputs.parameters.report-uri}}',
            },
            {
              name: 'AGR_WORKFLOW_OUTPUT_FILE',
              value: '/tmp/decision.json',
            },
          ],
          image: 'ghcr.io/walnuts1018/agr-training:0.1.15@sha256:caba8be0b12864071e4958abdf1a768a022b2549947c4cd8b1c2bc4d2b25c09b',
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
          securityContext: {
            allowPrivilegeEscalation: false,
            capabilities: {
              drop: [
                'ALL',
              ],
            },
            readOnlyRootFilesystem: true,
            runAsGroup: 10001,
            runAsNonRoot: true,
            runAsUser: 10001,
          },
          source: importstr '_workflow_templates/decide.sh',
          volumeMounts: [
            {
              mountPath: '/etc/agr',
              name: 'learning-settings',
              readOnly: true,
            },
            {
              mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
              name: 'sts-token',
              readOnly: true,
            },
            {
              mountPath: '/tmp',
              name: 'tmp',
            },
          ],
        },
        serviceAccountName: 'agr-evaluator',
        volumes: [
          {
            configMap: {
              name: 'learning-settings',
            },
            name: 'learning-settings',
          },
          {
            name: 'sts-token',
            projected: {
              sources: [
                {
                  serviceAccountToken: {
                    audience: 'sts.seaweedfs.com',
                    expirationSeconds: 3600,
                    path: 'token',
                  },
                },
              ],
            },
          },
          {
            emptyDir: {
              sizeLimit: '1Gi',
            },
            name: 'tmp',
          },
        ],
      },
      {
        container: {
          args: [
            '--target-id',
            '{{tasks.train.outputs.parameters.model-id}}',
            '--active-pointer-s3-uri',
            's3://agr-ai/worker-runs/models/active.json',
          ],
          command: [
            '/app/.venv/bin/agr-publish',
          ],
          env: [
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
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
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
              value: 'ghcr.io/walnuts1018/agr-training:0.1.15@sha256:caba8be0b12864071e4958abdf1a768a022b2549947c4cd8b1c2bc4d2b25c09b',
            },
            {
              name: 'AGR_WORKFLOW_UID',
              value: '{{workflow.uid}}',
            },
            {
              name: 'AGR_EVALUATION_REPORT_URI',
              value: '{{tasks.aggregate.outputs.parameters.report-uri}}',
            },
            {
              name: 'AGR_WORKFLOW_GENERATION_ID',
              value: '{{tasks.plan.outputs.parameters.generation-id}}',
            },
            {
              name: 'AGR_WORKFLOW_PLAN_URI',
              value: '{{tasks.plan.outputs.parameters.plan-uri}}',
            },
            {
              name: 'AGR_WORKFLOW_OUTPUT_FILE',
              value: '/tmp/publish.json',
            },
          ],
          image: 'ghcr.io/walnuts1018/agr-training:0.1.15@sha256:caba8be0b12864071e4958abdf1a768a022b2549947c4cd8b1c2bc4d2b25c09b',
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
          securityContext: {
            allowPrivilegeEscalation: false,
            capabilities: {
              drop: [
                'ALL',
              ],
            },
            readOnlyRootFilesystem: true,
            runAsGroup: 10001,
            runAsNonRoot: true,
            runAsUser: 10001,
          },
          volumeMounts: [
            {
              mountPath: '/etc/agr',
              name: 'learning-settings',
              readOnly: true,
            },
            {
              mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
              name: 'sts-token',
              readOnly: true,
            },
            {
              mountPath: '/tmp',
              name: 'tmp',
            },
          ],
        },
        name: 'publish',
        podSpecPatch: podSpecPatch,
        serviceAccountName: 'agr-promoter',
        volumes: [
          {
            configMap: {
              name: 'learning-settings',
            },
            name: 'learning-settings',
          },
          {
            name: 'sts-token',
            projected: {
              sources: [
                {
                  serviceAccountToken: {
                    audience: 'sts.seaweedfs.com',
                    expirationSeconds: 3600,
                    path: 'token',
                  },
                },
              ],
            },
          },
          {
            emptyDir: {
              sizeLimit: '2Gi',
            },
            name: 'tmp',
          },
        ],
      },
      {
        container: {
          args: [
          ],
          command: [
            '/app/.venv/bin/agr-verify-deployment',
          ],
          env: [
            {
              name: 'AWS_ENDPOINT_URL_S3',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
            },
            {
              name: 'AWS_ENDPOINT_URL_STS',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
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
              value: 'ghcr.io/walnuts1018/agr-training:0.1.15@sha256:caba8be0b12864071e4958abdf1a768a022b2549947c4cd8b1c2bc4d2b25c09b',
            },
            {
              name: 'AGR_WORKFLOW_UID',
              value: '{{workflow.uid}}',
            },
            {
              name: 'AGR_WORKFLOW_GENERATION_ID',
              value: '{{tasks.plan.outputs.parameters.generation-id}}',
            },
            {
              name: 'AGR_WORKFLOW_PLAN_URI',
              value: '{{tasks.plan.outputs.parameters.plan-uri}}',
            },
            {
              name: 'AGR_SERVER_SERVICE_HEALTH_URL',
              value: 'http://agr-server.agr.svc.cluster.local:8081',
            },
            {
              name: 'AGR_WORKFLOW_OUTPUT_FILE',
              value: '/tmp/verify.json',
            },
          ],
          image: 'ghcr.io/walnuts1018/agr-training:0.1.15@sha256:caba8be0b12864071e4958abdf1a768a022b2549947c4cd8b1c2bc4d2b25c09b',
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
          securityContext: {
            allowPrivilegeEscalation: false,
            capabilities: {
              drop: [
                'ALL',
              ],
            },
            readOnlyRootFilesystem: true,
            runAsGroup: 10001,
            runAsNonRoot: true,
            runAsUser: 10001,
          },
          volumeMounts: [
            {
              mountPath: '/etc/agr',
              name: 'learning-settings',
              readOnly: true,
            },
            {
              mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
              name: 'sts-token',
              readOnly: true,
            },
            {
              mountPath: '/tmp',
              name: 'tmp',
            },
          ],
        },
        name: 'verify',
        podSpecPatch: podSpecPatch,
        serviceAccountName: 'agr-verify',
        volumes: [
          {
            configMap: {
              name: 'learning-settings',
            },
            name: 'learning-settings',
          },
          {
            name: 'sts-token',
            projected: {
              sources: [
                {
                  serviceAccountToken: {
                    audience: 'sts.seaweedfs.com',
                    expirationSeconds: 3600,
                    path: 'token',
                  },
                },
              ],
            },
          },
          {
            emptyDir: {
              sizeLimit: '1Gi',
            },
            name: 'tmp',
          },
        ],
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
          manifest: importstr '_workflow_templates/job-rollout.yaml',
          setOwnerReference: true,
        },
      },
      {
        name: 'wait-rollout-indexed-job',
        resource: {
          action: 'get',
          failureCondition: import '_workflow_templates/indexed-job-failure-condition.libsonnet',
          manifest: importstr '_workflow_templates/job-rollout-reference.yaml',
          successCondition: 'status.succeeded == spec.completions',
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
          manifest: importstr '_workflow_templates/job-assess.yaml',
          setOwnerReference: true,
        },
      },
      {
        name: 'wait-assess-indexed-job',
        resource: {
          action: 'get',
          failureCondition: import '_workflow_templates/indexed-job-failure-condition.libsonnet',
          manifest: importstr '_workflow_templates/job-assess-reference.yaml',
          successCondition: 'status.succeeded == spec.completions',
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
              depends: 'delete-rollout.Succeeded && delete-assess.Succeeded',
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
          manifest: importstr '_workflow_templates/resource-delete-rollout.yaml',
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
          manifest: importstr '_workflow_templates/resource-delete-assess.yaml',
        },
      },
      {
        name: 'finalize',
        podSpecPatch: podSpecPatch,
        script: {
          command: [
            '/bin/sh',
            '-e',
          ],
          env: [
            {
              name: 'AWS_ENDPOINT_URL_S3',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
            },
            {
              name: 'AWS_ENDPOINT_URL_STS',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
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
              value: 'ghcr.io/walnuts1018/agr-training:0.1.15@sha256:caba8be0b12864071e4958abdf1a768a022b2549947c4cd8b1c2bc4d2b25c09b',
            },
            {
              name: 'AGR_WORKFLOW_UID',
              value: '{{workflow.uid}}',
            },
            {
              name: 'AGR_WORKFLOW_GENERATION_ID',
              value: '{{workflow.outputs.parameters.generation-id}}',
            },
            {
              name: 'AGR_WORKFLOW_ATTEMPT_ID',
              value: '{{workflow.outputs.parameters.attempt-id}}',
            },
          ],
          image: 'ghcr.io/walnuts1018/agr-training:0.1.15@sha256:caba8be0b12864071e4958abdf1a768a022b2549947c4cd8b1c2bc4d2b25c09b',
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
          securityContext: {
            allowPrivilegeEscalation: false,
            capabilities: {
              drop: [
                'ALL',
              ],
            },
            readOnlyRootFilesystem: true,
            runAsGroup: 10001,
            runAsNonRoot: true,
            runAsUser: 10001,
          },
          source: importstr '_workflow_templates/finalize.sh',
          volumeMounts: [
            {
              mountPath: '/etc/agr',
              name: 'learning-settings',
              readOnly: true,
            },
            {
              mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
              name: 'sts-token',
              readOnly: true,
            },
            {
              mountPath: '/tmp',
              name: 'tmp',
            },
          ],
        },
        serviceAccountName: 'agr-planner',
        volumes: [
          {
            configMap: {
              name: 'learning-settings',
            },
            name: 'learning-settings',
          },
          {
            name: 'sts-token',
            projected: {
              sources: [
                {
                  serviceAccountToken: {
                    audience: 'sts.seaweedfs.com',
                    expirationSeconds: 3600,
                    path: 'token',
                  },
                },
              ],
            },
          },
          {
            emptyDir: {
              sizeLimit: '1Gi',
            },
            name: 'tmp',
          },
        ],
      },
      {
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
          ],
        },
        podSpecPatch: podSpecPatch,
        script: {
          command: [
            '/bin/sh',
            '-e',
          ],
          env: [
            {
              name: 'AGR_WORKFLOW_NAME',
              value: '{{workflow.name}}',
            },
            {
              name: 'AWS_ENDPOINT_URL_S3',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
            },
            {
              name: 'AWS_ENDPOINT_URL_STS',
              value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
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
              value: 'ghcr.io/walnuts1018/agr-training:0.1.15@sha256:caba8be0b12864071e4958abdf1a768a022b2549947c4cd8b1c2bc4d2b25c09b',
            },
            {
              name: 'AGR_WORKFLOW_UID',
              value: '{{workflow.uid}}',
            },
            {
              name: 'AGR_WORKFLOW_OUTPUT_FILE',
              value: '/tmp/create-attempt.json',
            },
            {
              name: 'AGR_WORKFLOW_TRIGGER',
              value: '{{workflow.parameters.trigger}}',
            },
            {
              name: 'AGR_WORKFLOW_RETRY_GENERATION_ID',
              value: '{{workflow.parameters.retry-generation-id}}',
            },
          ],
          image: 'ghcr.io/walnuts1018/agr-training:0.1.15@sha256:caba8be0b12864071e4958abdf1a768a022b2549947c4cd8b1c2bc4d2b25c09b',
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
          securityContext: {
            allowPrivilegeEscalation: false,
            capabilities: {
              drop: [
                'ALL',
              ],
            },
            readOnlyRootFilesystem: true,
            runAsGroup: 10001,
            runAsNonRoot: true,
            runAsUser: 10001,
          },
          source: importstr '_workflow_templates/create-attempt.sh',
          volumeMounts: [
            {
              mountPath: '/etc/agr',
              name: 'learning-settings',
              readOnly: true,
            },
            {
              mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
              name: 'sts-token',
              readOnly: true,
            },
            {
              mountPath: '/tmp',
              name: 'tmp',
            },
          ],
        },
        serviceAccountName: 'agr-planner',
        volumes: [
          {
            configMap: {
              name: 'learning-settings',
            },
            name: 'learning-settings',
          },
          {
            name: 'sts-token',
            projected: {
              sources: [
                {
                  serviceAccountToken: {
                    audience: 'sts.seaweedfs.com',
                    expirationSeconds: 3600,
                    path: 'token',
                  },
                },
              ],
            },
          },
          {
            emptyDir: {
              sizeLimit: '1Gi',
            },
            name: 'tmp',
          },
        ],
      },
    ],
    ttlStrategy: {
      secondsAfterCompletion: 604800,
    },
  },
}
