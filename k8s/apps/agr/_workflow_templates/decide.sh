# shellcheck shell=sh
/app/.venv/bin/agr-decide-promotion > /tmp/decision.json
/app/.venv/bin/python -c 'import json,pathlib; d=json.load(open("/tmp/decision.json")); pathlib.Path("/tmp/promote").write_text(str(d["promote"]).lower())'
