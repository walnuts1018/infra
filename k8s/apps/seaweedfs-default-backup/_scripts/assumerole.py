#!/usr/bin/env python3
"""AWS credential_process helper: exchanges the pod's projected SeaweedFS STS
token for temporary S3 credentials via AssumeRoleWithWebIdentity."""

import json
import subprocess
import sys
import time

ROLE_ARN = "arn:aws:iam::role/seaweedfs-default-backup"
WEB_IDENTITY_TOKEN_FILE = "/var/run/secrets/sts.seaweedfs.com/serviceaccount/token"
STS_ENDPOINT_URL = "http://seaweedfs-default-filer.seaweedfs.svc.cluster.local:8333"


def assume_role() -> dict[str, str | int]:
    result = subprocess.run(
        [
            "aws",
            "sts",
            "assume-role-with-web-identity",
            "--role-arn",
            ROLE_ARN,
            "--role-session-name",
            f"seaweedfs-default-backup-session-{int(time.time())}",
            "--duration-seconds",
            "86400",
            "--web-identity-token",
            f"file://{WEB_IDENTITY_TOKEN_FILE}",
            "--endpoint-url",
            STS_ENDPOINT_URL,
            "--region",
            "us-east-1",
        ],
        capture_output=True,
        text=True,
        check=True,
    )
    credentials = json.loads(result.stdout)["Credentials"]
    return {
        "Version": 1,
        "AccessKeyId": credentials["AccessKeyId"],
        "SecretAccessKey": credentials["SecretAccessKey"],
        "SessionToken": credentials["SessionToken"],
        "Expiration": credentials["Expiration"],
    }


def main() -> None:
    try:
        print(json.dumps(assume_role()))
    except subprocess.CalledProcessError as e:
        sys.stderr.write(e.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
