# shellcheck shell=sh
/app/.venv/bin/agr-validate
/app/.venv/bin/python -c 'import json,os,pathlib; d=json.load(open(os.environ["AGR_WORKFLOW_OUTPUT_FILE"])); out=pathlib.Path("/tmp/validate-output"); out.mkdir(); [(out/name).write_text(str(d[key])) for name,key in [("artifact-uri","artifact_uri"),("model-sha256","model_sha256"),("manifest-sha256","manifest_sha256"),("validation-uri","validation_uri")]]; raise SystemExit(0 if d.get("validation_passed") is True else 1)'
