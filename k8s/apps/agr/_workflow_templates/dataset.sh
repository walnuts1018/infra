/app/.venv/bin/agr-build-dataset
/app/.venv/bin/python -c 'import json,pathlib; d=json.load(open("/tmp/dataset.json")); pathlib.Path("/tmp/dataset-uri").write_text(str(d["artifact_uri"]))'
