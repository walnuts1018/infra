#!/usr/bin/env python3

import argparse
import collections
import json
from pathlib import Path


SEVERITY_ORDER = {
    "CRITICAL": 0,
    "HIGH": 1,
    "MEDIUM": 2,
    "LOW": 3,
    "UNKNOWN": 4,
}
MAX_ROWS = 60


def load_findings(report_path):
    with report_path.open(encoding="utf-8") as report_file:
        report = json.load(report_file)

    counts = collections.Counter()
    details = {}
    for result in report.get("Results") or []:
        target = result.get("Target") or "(unknown target)"
        for finding in result.get("Misconfigurations") or []:
            rule_id = finding.get("AVDID") or finding.get("ID") or "(unknown rule)"
            severity = (finding.get("Severity") or "UNKNOWN").upper()
            title = finding.get("Title") or finding.get("Message") or "(untitled finding)"
            key = (target, rule_id, severity, title)
            counts[key] += 1
            details[key] = {
                "target": f"k8s/snapshots/{target}",
                "rule_id": rule_id,
                "severity": severity,
                "title": title,
                "resolution": (
                    finding.get("Resolution") or finding.get("Message") or ""
                ),
            }

    return counts, details


def markdown_cell(value, limit=240):
    cell = (
        str(value)
        .replace("|", "\\|")
        .replace("\r", " ")
        .replace("\n", " ")
        .strip()
    )
    if len(cell) > limit:
        return cell[: limit - 1] + "…"
    return cell


def render_markdown(additions, total_added):
    if total_added == 0:
        return (
            "## Trivy config scan\n\n"
            "No new misconfiguration finding instances were found compared with "
            "the manifests published from `main` on the `snapshot` branch. "
            "Existing findings do not block this CI.\n"
        )

    severity_counts = collections.Counter()
    for detail, count in additions:
        severity_counts[detail["severity"]] += count

    summary = ", ".join(
        f"{severity}: {severity_counts[severity]}"
        for severity in SEVERITY_ORDER
        if severity_counts[severity]
    )
    lines = [
        "## New Trivy config findings",
        "",
        f"Trivy found **{total_added} additional finding instances** compared with "
        f"the manifests published from `main` on the `snapshot` branch "
        f"({summary}). These findings do not fail CI.",
        "",
        "| Severity | Rule | Rendered manifest | Finding | Remediation | Added |",
        "| --- | --- | --- | --- | --- | ---: |",
    ]

    for detail, count in additions[:MAX_ROWS]:
        target = detail["target"].replace("`", "'")
        lines.append(
            (
                "| {severity} | `{rule}` | `{target}` | {title} | "
                "{resolution} | +{count} |"
            ).format(
                severity=markdown_cell(detail["severity"]),
                rule=markdown_cell(detail["rule_id"]),
                target=markdown_cell(target),
                title=markdown_cell(detail["title"]),
                resolution=markdown_cell(detail["resolution"]),
                count=count,
            )
        )

    omitted = len(additions) - MAX_ROWS
    if omitted > 0:
        lines.extend(["", f"{omitted} additional rule and target groups are omitted."])

    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser(description="Compare Trivy config reports.")
    parser.add_argument("--base-report", type=Path, required=True)
    parser.add_argument("--head-report", type=Path, required=True)
    parser.add_argument("--markdown-output", type=Path, required=True)
    parser.add_argument("--github-output", type=Path)
    args = parser.parse_args()

    base_counts, _ = load_findings(args.base_report)
    head_counts, head_details = load_findings(args.head_report)
    additions = []
    for key, count in head_counts.items():
        added = count - base_counts[key]
        if added > 0:
            additions.append((head_details[key], added))

    additions.sort(
        key=lambda item: (
            SEVERITY_ORDER.get(item[0]["severity"], len(SEVERITY_ORDER)),
            item[0]["target"],
            item[0]["rule_id"],
            item[0]["title"],
        )
    )
    total_added = sum(count for _, count in additions)
    args.markdown_output.write_text(
        render_markdown(additions, total_added), encoding="utf-8"
    )

    if args.github_output:
        with args.github_output.open("a", encoding="utf-8") as output_file:
            output_file.write("ready=true\n")
            output_file.write(
                f"findings-added={'true' if total_added else 'false'}\n"
            )


if __name__ == "__main__":
    main()
