local app = import 'app.json5';
(import '../../components/configmap.libsonnet') {
  name: 'learning-settings',
  namespace: app.namespace,
  use_suffix: false,
  data: {
    'learning-settings.json': std.manifestJson({
      schema_version: 1,
      auto_enabled: true,
      episodes_per_generation: 1600,
      episodes_per_shard: 16,
      actor_pods: 1,
      episodes_per_actor: 1,
      evaluation_pods: 1,
      evaluation_paired_seeds_per_config: 100,
      evaluation_bootstrap_resamples: 10000,
      analysis_rollouts: 8,
      analysis_duration_ms: 100,
      eval_min_effect: 0,
      eval_per_config_regression_floor: -0.05,
    }),
  },
}
