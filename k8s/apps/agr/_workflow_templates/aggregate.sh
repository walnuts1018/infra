/app/.venv/bin/agr-aggregate-evaluation > /tmp/aggregate.json
/app/.venv/bin/python -c 'import json,pathlib; d=json.load(open("/tmp/aggregate.json")); pathlib.Path("/tmp/report-uri").write_text(str(d["artifact_uri"]))'
