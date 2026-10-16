#!/usr/bin/env python3
"""Compare Trivy config JSON reports and render new findings as Markdown.

Findings are compared per (target file, rule, severity, title, Kubernetes
resource). The resource identity (kind/namespace/name) is resolved from the
scanned manifest: Trivy reports only the file plus a cause line span, and a
single rendered file can contain many resources, so counting per file would
miss a fix in one resource coinciding with the same rule firing in another.
Line numbers alone are unsuitable as identity (unrelated insertions shift
them), hence the logical resource ID. No infrautil changes are needed.
"""

from __future__ import annotations

import argparse
import collections
import json
import re
from pathlib import Path
from typing import Any


SEVERITY_ORDER: dict[str, int] = {
    "CRITICAL": 0,
    "HIGH": 1,
    "MEDIUM": 2,
    "LOW": 3,
    "UNKNOWN": 4,
}
MAX_ROWS = 60

FindingKey = tuple[str, str, str, str, str, str, str]
FindingDetail = dict[str, str]

_DOC_SEP = re.compile(r"^---(?:\s|$)")
_KIND = re.compile(r"^kind:\s*(\S+)\s*$")
_METADATA = re.compile(r"^(\s*)metadata:\s*(?:#.*)?$")
_NAME = re.compile(r"^(\s*)(?:name|namespace):\s*(\S+)\s*$")


def parse_resource_id(manifest: Path, start: int | None) -> tuple[str, str, str]:
    """Return (kind, namespace, name) of the document containing start line."""
    try:
        text = manifest.read_text(encoding="utf-8")
    except OSError:
        return ("?", "?", "?")
    docs: list[list[str]] = [[]]
    for line in text.splitlines():
        if _DOC_SEP.match(line):
            docs.append([])
        else:
            docs[-1].append(line)
    # 1-based line numbers; separator lines belong to no document.
    lineno = 0
    chosen: list[str] | None = None
    for doc in docs:
        for line in doc:
            lineno += 1
            if start is not None and lineno == start:
                chosen = doc
                break
        else:
            lineno += 1  # separator line
            continue
        break
    if chosen is None:
        return ("?", "?", "?")
    kind = name = ns = "?"
    m = next((m for m in (_KIND.match(l) for l in chosen) if m), None)
    if m:
        kind = m.group(1).strip("\"'")
    meta_indent: int | None = None
    for line in chosen:
        if meta_indent is None:
            mm = _METADATA.match(line)
            if mm:
                meta_indent = len(mm.group(1).replace("\t", "        "))
            continue
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        indent = len(line) - len(line.lstrip(" "))
        if indent <= meta_indent:
            break
        nm = _NAME.match(line)
        if nm:
            field = nm.group(0).split(":", 1)[0].strip()
            val = nm.group(2).strip("\"'")
            if field == "name" and name == "?":
                name = val
            elif field == "namespace" and ns == "?":
                ns = val
    return (kind, ns, name)


def load_findings(
    report_path: Path, manifest_dir: Path | None = None
) -> tuple[collections.Counter[FindingKey], dict[FindingKey, FindingDetail]]:
    with report_path.open(encoding="utf-8") as report_file:
        report: dict[str, Any] = json.load(report_file)

    counts: collections.Counter[FindingKey] = collections.Counter()
    details: dict[FindingKey, FindingDetail] = {}
    for result in report.get("Results") or []:
        target = result.get("Target") or "(unknown target)"
        for finding in result.get("Misconfigurations") or []:
            rule_id = finding.get("AVDID") or finding.get("ID") or "(unknown rule)"
            severity = (finding.get("Severity") or "UNKNOWN").upper()
            title = (
                finding.get("Title") or finding.get("Message") or "(untitled finding)"
            )
            cause = finding.get("CauseMetadata") or {}
            kind, ns, name = ("?", "?", "?")
            if manifest_dir is not None:
                start = cause.get("StartLine")
                kind, ns, name = parse_resource_id(
                    manifest_dir / target,
                    start if isinstance(start, int) else None,
                )
            key: FindingKey = (target, rule_id, severity, title, kind, ns, name)
            counts[key] += 1
            resource = f"{kind}/{ns}/{name}" if (kind, ns, name) != ("?", "?", "?") else "?"
            details[key] = {
                "target": f"k8s/snapshots/{target}",
                "rule_id": rule_id,
                "severity": severity,
                "title": title,
                "resource": resource,
                "resolution": (
                    finding.get("Resolution") or finding.get("Message") or ""
                ),
            }

    return counts, details


def markdown_cell(value: object, limit: int = 240) -> str:
    cell = str(value).replace("|", "\\|").replace("\r", " ").replace("\n", " ").strip()
    if len(cell) > limit:
        return cell[: limit - 1] + "…"
    return cell


def render_markdown(
    additions: list[tuple[FindingDetail, int]], total_added: int
) -> str:
    if total_added == 0:
        return (
            "## Trivy config scan\n\n"
            "No new misconfiguration finding instances were found compared with "
            "the manifests published from `main` on the `snapshot` branch. "
            "Existing findings do not block this CI.\n"
        )

    severity_counts: collections.Counter[str] = collections.Counter()
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
        f"({summary}).",
        "",
        "| Severity | Rule | Rendered manifest | Resource | Finding | Remediation | Added |",
        "| --- | --- | --- | --- | --- | --- | ---: |",
    ]

    for detail, count in additions[:MAX_ROWS]:
        target = detail["target"].replace("`", "'")
        lines.append(
            (
                "| {severity} | `{rule}` | `{target}` | `{resource}` | {title} | "
                "{resolution} | +{count} |"
            ).format(
                severity=markdown_cell(detail["severity"]),
                rule=markdown_cell(detail["rule_id"]),
                target=markdown_cell(target),
                resource=markdown_cell(detail.get("resource", "?"), limit=120),
                title=markdown_cell(detail["title"]),
                resolution=markdown_cell(detail["resolution"]),
                count=count,
            )
        )

    omitted = len(additions) - MAX_ROWS
    if omitted > 0:
        lines.extend(["", f"{omitted} additional rule and target groups are omitted."])

    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description="Compare Trivy config reports.")
    parser.add_argument("--base-report", type=Path, required=True)
    parser.add_argument("--head-report", type=Path, required=True)
    parser.add_argument("--markdown-output", type=Path, required=True)
    parser.add_argument("--github-output", type=Path)
    parser.add_argument("--base-dir", type=Path, default=None,
                        help="Manifest root the base report was scanned from")
    parser.add_argument("--head-dir", type=Path, default=None,
                        help="Manifest root the head report was scanned from")
    args = parser.parse_args()

    base_counts, _ = load_findings(args.base_report, args.base_dir)
    head_counts, head_details = load_findings(args.head_report, args.head_dir)
    additions: list[tuple[FindingDetail, int]] = []
    for key, count in head_counts.items():
        added = count - base_counts[key]
        if added > 0:
            additions.append((head_details[key], added))

    additions.sort(
        key=lambda item: (
            SEVERITY_ORDER.get(item[0]["severity"], len(SEVERITY_ORDER)),
            item[0]["target"],
            item[0]["rule_id"],
            item[0].get("resource", "?"),
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
            output_file.write(f"findings-added={'true' if total_added else 'false'}\n")


if __name__ == "__main__":
    main()
