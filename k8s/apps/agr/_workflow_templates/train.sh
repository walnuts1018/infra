# shellcheck shell=sh
set -- --s3-input-uri "$AGR_WORKFLOW_INPUT_URI" --s3-output-uri "$AGR_WORKFLOW_OUTPUT_URI" --behavior-policy-id shared-policy-v2
if [ -n "$AGR_WORKFLOW_LEARNER_URI" ]; then
  set -- "$@" --initial-artifact-uri "$AGR_WORKFLOW_LEARNER_URI"
fi
if [ -n "$AGR_WORKFLOW_BEHAVIOR_POLICY_SHA256" ]; then
  set -- "$@" --behavior-policy-artifact-sha256 "$AGR_WORKFLOW_BEHAVIOR_POLICY_SHA256"
fi
/app/.venv/bin/agr-train "$@"
/app/.venv/bin/python -c 'import json,pathlib; d=json.load(open("/tmp/train.json")); out=pathlib.Path("/tmp/train-output"); out.mkdir(); [(out/name).write_text(str(d[key])) for name,key in [("artifact-uri","artifact_uri"),("model-sha256","model_sha256"),("manifest-sha256","manifest_sha256"),("model-id","model_id")]]'
