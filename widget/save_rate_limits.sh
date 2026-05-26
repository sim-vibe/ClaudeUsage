#!/bin/bash
# statusLine script: saves rate_limits from Claude Code to file for the SwiftBar widget.
input=$(cat)

changed=$(python3 -c "
import json, sys, os
d = json.load(sys.stdin)
rl = d.get('rate_limits', {})
if not rl:
    sys.exit(0)
path = os.path.expanduser('~/.claude/widgets/rate_limits.json')
try:
    old = open(path).read()
except:
    old = ''
new = json.dumps(rl, sort_keys=True)
if old != new:
    with open(path, 'w') as f:
        f.write(new)
    print('changed')
" <<< "$input")

# 값이 바뀐 경우에만 SwiftBar에 즉시 새로고침 요청
if [ "$changed" = "changed" ]; then
    open "swiftbar://refreshPlugin?name=claude_usage.1s.sh" 2>/dev/null &
fi

# Output compact usage for Claude Code's status line UI
python3 -c "
import json, sys
d = json.load(sys.stdin)
rl = d.get('rate_limits', {})
fh = rl.get('five_hour', {})
sd = rl.get('seven_day', {})
parts = []
if fh: parts.append(f\"5h:{fh.get('used_percentage',0):.0f}%\")
if sd: parts.append(f\"7d:{sd.get('used_percentage',0):.0f}%\")
print(' | '.join(parts))
" <<< "$input" 2>/dev/null
