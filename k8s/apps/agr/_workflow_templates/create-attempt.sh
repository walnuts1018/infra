/app/.venv/bin/agr-create-attempt
/app/.venv/bin/python -c 'import json,pathlib; d=json.load(open("/tmp/create-attempt.json")); out=pathlib.Path("/tmp/create-attempt-output"); out.mkdir(); [(out/name).write_text(str(d[key])) for name,key in [("generation-id","generation_id"),("generation-number","generation_number"),("attempt-id","attempt_id")]]'
