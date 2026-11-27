#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

VERSION_STR="$(tr -d '[:space:]' < VERSION)"

# 1. Verify JSON files parse strictly (no duplicate keys) and match VERSION
python3 -c '
import json, sys
def no_dups(pairs):
    seen = set()
    for k, _ in pairs:
        if k in seen: raise ValueError(f"Duplicate JSON key: {k}")
        seen.add(k)
    return dict(pairs)
for p in sys.argv[1:]:
    with open(p) as f: json.load(f, object_pairs_hook=no_dups)
' manifest.json plugin.json .claude-plugin/plugin.json .claude-plugin/marketplace.json .codex-plugin/plugin.json .cursor-plugin/plugin.json gemini-extension.json
for jf in manifest.json plugin.json .claude-plugin/plugin.json .codex-plugin/plugin.json .cursor-plugin/plugin.json gemini-extension.json; do
  v="$(jq -r '.version' "$jf")"
  [[ "$v" == "$VERSION_STR" ]] || { echo "FAIL: $jf version ($v) != VERSION ($VERSION_STR)"; exit 1; }
done
mv="$(jq -r '.plugins[0].version' .claude-plugin/marketplace.json)"
[[ "$mv" == "$VERSION_STR" ]] || { echo "FAIL: marketplace.json version ($mv) != VERSION ($VERSION_STR)"; exit 1; }
sd_len="$(jq -r '.interface.shortDescription | length' .codex-plugin/plugin.json)"
(( sd_len > 0 && sd_len <= 30 )) || { echo "FAIL: .codex-plugin shortDescription length ($sd_len) must be 1..30"; exit 1; }
for rv in $(jq -r '.routines[].version' manifest.json); do
  [[ "$rv" == "$VERSION_STR" ]] || { echo "FAIL: routine version ($rv) != VERSION ($VERSION_STR)"; exit 1; }
done
for mf in README.md routines/groom.md routines/runner.md; do
  grep -Fq "v$VERSION_STR" "$mf" || { echo "FAIL: $mf missing v$VERSION_STR"; exit 1; }
done

# 2. Verify OpenCode symlinks and shared rules
[[ -L .opencode/skills && -d .opencode/skills ]] || { echo "FAIL: .opencode/skills symlink broken"; exit 1; }
[[ -L .opencode/references && -d .opencode/references ]] || { echo "FAIL: .opencode/references symlink broken"; exit 1; }
[[ -f references/rules.md ]] || { echo "FAIL: references/rules.md missing"; exit 1; }

# 3. Verify skills in manifest match skills/ folders and have valid frontmatter
MANIFEST_SKILLS="$(jq -r '(.coreSkills + .fullSkills)[]' manifest.json | sort)"
DISK_SKILLS="$(find skills -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)"
[[ "$MANIFEST_SKILLS" == "$DISK_SKILLS" ]] || {
  echo "FAIL: manifest skills differ from skills/ directories"
  diff -u <(echo "$MANIFEST_SKILLS") <(echo "$DISK_SKILLS") || true
  exit 1
}

for s in $MANIFEST_SKILLS; do
  f="skills/$s/SKILL.md"
  [[ -f "$f" ]] || { echo "FAIL: missing $f"; exit 1; }
  head -n 1 "$f" | grep -qx -- '---' || { echo "FAIL: $f missing YAML frontmatter start"; exit 1; }
  fm="$(awk 'NR==1{next} /^---$/{exit} {print}' "$f")"
  echo "$fm" | grep -q "^name: $s$" || { echo "FAIL: $f frontmatter name != $s"; exit 1; }
  echo "$fm" | grep -q "^description: ." || { echo "FAIL: $f missing description"; exit 1; }
  grep -q "/$s" README.md || { echo "FAIL: /$s missing from README.md"; exit 1; }
done

# 4. Verify all manifest labels appear in README.md
for lbl in $(jq -r '.labels[].name' manifest.json); do
  grep -Fq "\`$lbl\`" README.md || { echo "FAIL: label $lbl missing from README.md"; exit 1; }
done

# 5. Verify relative markdown links resolve
python3 - <<'PY'
import glob, os, re, sys
files = ["AGENTS.md", "CLAUDE.md", "GEMINI.md", "README.md", "SETUP.md", "references/rules.md"] + sorted(glob.glob("routines/*.md")) + sorted(glob.glob("skills/*/SKILL.md"))
for f in files:
    txt = open(f).read()
    for m in re.finditer(r"\[([^\]]+)\]\(([^)]+)\)", txt):
        target = m.group(2)
        if not target.startswith(("http://", "https://", "#", "mailto:", "customization://", "conversation://", "file://")):
            norm = os.path.normpath(os.path.join(os.path.dirname(f), target))
            if not os.path.exists(norm):
                print(f"FAIL: broken link in {f}: {target} -> {norm}")
                sys.exit(1)
PY

echo "OK: workflow v$VERSION_STR validated ($(echo "$MANIFEST_SKILLS" | wc -l | tr -d ' ') skills, $(jq '.labels | length' manifest.json) labels)."
