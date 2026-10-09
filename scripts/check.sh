#!/usr/bin/env bash
# Check the skill text against the live API contract, plugin.json against the
# OpenAPI version, and the skill bytes against the copy Formbear serves.
# The byte compare fails until those bytes are published at the well-known URL.
# Also reject em dashes.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"

if git grep -n -I $'\u2014' -- . >/tmp/formbear-emdash.txt; then
  echo "Remove em dashes:"
  cat /tmp/formbear-emdash.txt
  exit 1
fi

python3 - << 'PY'
from pathlib import Path
skill = Path("skills/formbear/SKILL.md").read_text()
agents = Path("AGENTS.md").read_text()
pro_line = next(line for line in skill.splitlines() if line.startswith("Pro write tools:"))
if "list_form_versions" in pro_line:
    raise SystemExit("list_form_versions is a read tool, not a Pro write")
if "list_form_versions" not in skill.split("Pro write tools:")[0]:
    raise SystemExit("list_form_versions should be documented with the read tools")
required = [
    "since",
    "until",
    "confirmDataLoss",
    "Idempotency-Key",
    "afterBlockId",
    '"type": "phone"',
    "idempotency_key_reused",
    "at least 3 completed responses",
    "already cached",
]
missing = [phrase for phrase in required if phrase not in skill]
if missing:
    raise SystemExit("skill is missing: " + ", ".join(missing))
if "never leave EU" in skill:
    raise SystemExit("skill still claims answers never leave EU infrastructure")
if 'summarize_responses` on the top one' in skill:
    raise SystemExit("month example still uses summarize_responses")
if '{ "error": { "code", "message", "hint" } }' not in agents:
    raise SystemExit("AGENTS.md error shape is not the nested envelope")
print("skill and AGENTS.md include the live API contract")
PY

curl -fsSL --retry 3 --retry-delay 2 -o /tmp/formbear-openapi.json https://formbear.app/openapi.json
python3 - << 'PY'
import json
plugin = json.load(open("plugin.json"))
spec = json.load(open("/tmp/formbear-openapi.json"))
plugin_version = plugin["version"]
api_version = spec["info"]["version"]
if plugin_version != api_version:
    raise SystemExit(
        f"plugin.json version {plugin_version} != OpenAPI info.version {api_version}"
    )
print(f"plugin.json version {plugin_version} matches OpenAPI")
PY

curl -fsSL --retry 3 --retry-delay 2 \
  -o /tmp/formbear-SKILL.md \
  https://formbear.app/.well-known/agent-skills/formbear/SKILL.md
if ! cmp -s skills/formbear/SKILL.md /tmp/formbear-SKILL.md; then
  echo "skills/formbear/SKILL.md differs from the copy Formbear serves."
  echo "Publish these bytes at https://formbear.app/.well-known/agent-skills/formbear/SKILL.md"
  diff -u /tmp/formbear-SKILL.md skills/formbear/SKILL.md || true
  exit 1
fi

echo "skill matches the served copy"
