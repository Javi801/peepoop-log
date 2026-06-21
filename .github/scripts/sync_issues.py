#!/usr/bin/env python3
import csv
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
ISSUES_DIR = ROOT / ".github" / "issues"
BACKLOG_PATH = ISSUES_DIR / "backlog.tsv"
DETAILS_PATH = ISSUES_DIR / "details.json"
LABELS_PATH = ISSUES_DIR / "labels.json"


def request(method, path, token, payload=None):
    url = f"https://api.github.com{path}"
    data = None
    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
        "X-GitHub-Api-Version": "2022-11-28",
        "User-Agent": "peepoop-log-issue-sync",
    }
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"

    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req) as response:
            body = response.read().decode("utf-8")
            return json.loads(body) if body else None
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8")
        raise RuntimeError(f"{method} {path} failed: {exc.code} {body}") from exc


def paginate(path, token):
    page = 1
    results = []
    while True:
        separator = "&" if "?" in path else "?"
        batch = request("GET", f"{path}{separator}per_page=100&page={page}", token)
        if not batch:
            return results
        results.extend(batch)
        if len(batch) < 100:
            return results
        page += 1


def load_backlog():
    with BACKLOG_PATH.open(newline="", encoding="utf-8") as file:
        rows = list(csv.DictReader(file, delimiter="\t"))

    issues = []
    for row in rows:
        title = row["Title"].strip()
        labels = [label.strip() for label in row["Labels"].split(",") if label.strip()]
        if title:
            issues.append({"title": title, "labels": labels, "status": row["Status"].strip()})
    return issues


def ensure_labels(repo, token):
    desired_labels = json.loads(LABELS_PATH.read_text(encoding="utf-8"))
    existing = {label["name"].lower(): label for label in paginate(f"/repos/{repo}/labels", token)}

    for label in desired_labels:
        name = label["name"]
        payload = {
            "name": name,
            "color": label["color"],
            "description": label["description"],
        }
        if name.lower() in existing:
            request(
                "PATCH",
                f"/repos/{repo}/labels/{urllib.parse.quote(name, safe='')}",
                token,
                payload,
            )
            print(f"Updated label: {name}")
        else:
            request("POST", f"/repos/{repo}/labels", token, payload)
            print(f"Created label: {name}")


def issue_body(issue, details):
    detail = details.get(issue["title"], {})
    body = detail.get("body", "").strip()
    footer = (
        "\n\n---\n"
        "Created from `.github/issues/backlog.tsv` by the backlog sync workflow."
    )
    return f"{body}{footer}" if body else footer.strip()


def sync_issues(repo, token):
    details = json.loads(DETAILS_PATH.read_text(encoding="utf-8"))
    desired = load_backlog()
    existing_issues = paginate(f"/repos/{repo}/issues?state=all", token)
    existing_titles = {
        issue["title"]: issue
        for issue in existing_issues
        if "pull_request" not in issue
    }

    for issue in desired:
        if issue["title"] in existing_titles:
            print(f"Exists: {issue['title']}")
            continue

        payload = {
            "title": issue["title"],
            "body": issue_body(issue, details),
            "labels": issue["labels"],
        }
        created = request("POST", f"/repos/{repo}/issues", token, payload)
        print(f"Created issue #{created['number']}: {issue['title']}")


def main():
    repo = os.environ.get("GITHUB_REPOSITORY")
    token = os.environ.get("GITHUB_TOKEN")
    if not repo:
        print("GITHUB_REPOSITORY is required, for example Javi801/peepoop-log", file=sys.stderr)
        return 2
    if not token:
        print("GITHUB_TOKEN is required", file=sys.stderr)
        return 2

    ensure_labels(repo, token)
    sync_issues(repo, token)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
