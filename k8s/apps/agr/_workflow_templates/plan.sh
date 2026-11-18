/app/.venv/bin/agr-plan
/app/.venv/bin/python - <<'PY'
import json
from pathlib import Path

plan_output = json.loads(Path("/tmp/plan.json").read_text())
output_directory = Path("/tmp/plan-output")
output_directory.mkdir()
outputs = {
    "generation-id": plan_output["generation_id"],
    "generation-number": plan_output["generation_number"],
    "attempt-id": plan_output["attempt_id"],
    "config-sha256": plan_output["config_sha256"],
    "plan-uri": plan_output["artifact_uri"],
    "rollout-shards": plan_output["rollout_shard_count"],
    "actor-pods": plan_output["actor_pods"],
    "evaluation-shards": plan_output["evaluation_shard_count"],
    "evaluation-pods": plan_output["evaluation_pods"],
    "learner-artifact-uri": plan_output["learner_artifact_uri"],
    "learner-sha256": plan_output["learner_sha256"],
}
for name, value in outputs.items():
    (output_directory / name).write_text(str(value))
PY
