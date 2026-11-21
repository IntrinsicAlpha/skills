#!/usr/bin/env bash
# Builds the ZIP uploaded at https://platform.openai.com/plugins (ChatGPT and Codex Plugin Directory).
# It contains only the portable plugin: plugin.json, mcp.json, the skill, and the icons plugin.json references.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
version="$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["version"])' "$root/plugin.json")"
out="$root/dist/intrinsic-alpha-openai-plugin-$version.zip"

mkdir -p "$root/dist"
rm -f "$out"
cd "$root"
zip -qr -X "$out" \
  plugin.json \
  mcp.json \
  skills/intrinsic-alpha \
  assets/app-icon.svg \
  assets/mark.svg \
  assets/mark-white.svg \
  -x '*.DS_Store'

echo "$out"
unzip -l "$out"
