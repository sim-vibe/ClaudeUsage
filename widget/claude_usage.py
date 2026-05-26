#!/usr/bin/env python3
"""Claude Code token usage widget for SwiftBar.
Reads rate_limits.json saved by the statusLine hook — exact server values, no estimation.
"""

import json
import os
import time
from datetime import datetime, timezone, timedelta

# Dance animation frames (20x20 pixel art robot, base64 PNG)
# Frame cycle: neutral → lean-right+up → wink → lean-left+up (every 2s)
_FRAMES = [
    "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAPElEQVR4nGNgoAd4VmHzH4RJlaOtgWfC9f9TgulnoAwXMxyja8InN4QNpFmkILsGGx54F1Js4CgYBQMIAIMPRD5frZskAAAAAElFTkSuQmCC",
    "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAPklEQVR4nGNgwAGeVdj8B2FS5XACig08E67/nxJMPwNluJjhGF0TPrkhbCDNIgXZNdjwwLuQYgNHwSgYTgAAyHdEPnnXhWwAAAAASUVORK5CYII=",
    "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAOElEQVR4nGNgoAd4VmHzH4RJlaOtgWfC9f9TgulnoAwXMxyPEANpFinILsWGB96FFBs4CkbBAAIAwMNOr1vWRjoAAAAASUVORK5CYII=",
    "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAQElEQVR4nGNgQAPPKmz+gzC6OCE5nIBqBp4J1/9PCaafgTJczHCMrgmf3BA2kGaRguwabHjgXUixgaNgFAwnAABuxkQ+edIaowAAAABJRU5ErkJggg==",
]

def current_frame_b64():
    # Custom frames can be placed at ~/.claude/widgets/robot_frame_{0-3}.png to override
    frame_idx = int(time.time()) % 4
    custom = os.path.expanduser(f'~/.claude/widgets/robot_frame_{frame_idx}.png')
    if os.path.exists(custom):
        import base64
        return base64.b64encode(open(custom, 'rb').read()).decode()
    return _FRAMES[frame_idx]

RATE_LIMITS_FILE = os.path.expanduser("~/.claude/widgets/rate_limits.json")
LOCAL_TZ = timezone(timedelta(hours=9))
NOP = "bash=/bin/echo terminal=false"


def fmt_reset(resets_at_epoch):
    now = datetime.now(LOCAL_TZ)
    dt = datetime.fromtimestamp(resets_at_epoch, tz=LOCAL_TZ)
    h = int(dt.strftime("%I")) or 12
    ampm = dt.strftime("%p").lower()
    m = dt.strftime("%M")
    time_str = f"{h}:{m}{ampm}" if m != "00" else f"{h}{ampm}"
    if dt <= now:
        return f"Reset today at {time_str} (Asia/Seoul)"
    if dt.date() == now.date():
        return f"Resets today at {time_str} (Asia/Seoul)"
    if dt.date() == (now + timedelta(days=1)).date():
        return f"Resets tomorrow at {time_str} (Asia/Seoul)"
    return f"Resets {dt.strftime('%b')} {dt.day} at {time_str} (Asia/Seoul)"


def progress_bar(pct, width=38):
    filled = round(min(pct, 100) / 100 * width)
    return "█" * filled + "░" * (width - filled)


def main():
    if not os.path.exists(RATE_LIMITS_FILE):
        print("🤖 — | color=gray")
        print("---")
        print(f"Claude Code 세션 후 표시됩니다 | color=gray {NOP}")
        return

    try:
        with open(RATE_LIMITS_FILE) as f:
            rl = json.load(f)
    except Exception as e:
        print("Claude ⚠ | color=red")
        print("---")
        print(f"Error: {e} | {NOP}")
        return

    file_age_min = (datetime.now().timestamp() - os.path.getmtime(RATE_LIMITS_FILE)) / 60
    now_ts = datetime.now().timestamp()

    fh  = rl.get("five_hour", {})
    sd  = rl.get("seven_day", {})
    sds = rl.get("seven_day_sonnet", {})

    s_pct  = fh.get("used_percentage", 0)
    w_pct  = sd.get("used_percentage", 0)
    ws_pct = sds.get("used_percentage") if sds else None

    # 5h 버킷이 이미 만료됐는지 확인
    fh_expired = fh.get("resets_at") and now_ts > fh["resets_at"]

    s_bar = progress_bar(s_pct)
    w_bar = progress_bar(w_pct)

    robot = current_frame_b64()
    usage_text = "0% · " if fh_expired else f"{s_pct:.0f}% · "
    print(f"{usage_text}{w_pct:.0f}%w | image={robot}")
    print("---")

    if fh_expired:
        print(f"⚠ 5h 버킷 만료 — Claude Code 응답 후 갱신됨 | color=orange {NOP}")
        print("---")
    elif file_age_min > 60:
        print(f"⚠ 데이터 {file_age_min:.0f}분 전 기준 | color=orange {NOP}")
        print("---")

    # Current session (5h)
    if fh_expired:
        print(f"Current session{' ' * 16}0% used | size=13 font=Menlo color=#000000 {NOP}")
        print(f"{progress_bar(0)} | font=Menlo color=#0055FF size=12 {NOP}")
        print(f"Next response will refresh | font=Menlo size=11 color=#888888 {NOP}")
    else:
        print(f"Current session{' ' * 16}{s_pct:.0f}% used | size=13 font=Menlo color=#000000 {NOP}")
        print(f"{s_bar} | font=Menlo color=#0055FF size=12 {NOP}")
        if fh.get("resets_at"):
            print(f"{fmt_reset(fh['resets_at'])} | font=Menlo size=11 color=#000000 {NOP}")
    print("---")

    # Current week (all models)
    print(f"Current week (all models){' ' * 7}{w_pct:.0f}% used | size=13 font=Menlo color=#000000 {NOP}")
    print(f"{w_bar} | font=Menlo color=#0055FF size=12 {NOP}")
    if sd.get("resets_at"):
        print(f"{fmt_reset(sd['resets_at'])} | font=Menlo size=11 color=#000000 {NOP}")
    print("---")

    # Current week (Sonnet only) — hook provides this only when available from server
    if ws_pct is not None:
        ws_bar = progress_bar(ws_pct)
        print(f"Current week (Sonnet only){' ' * 6}{ws_pct:.0f}% used | size=13 font=Menlo color=#000000 {NOP}")
        print(f"{ws_bar} | font=Menlo color=#0055FF size=12 {NOP}")
        if sds.get("resets_at"):
            print(f"{fmt_reset(sds['resets_at'])} | font=Menlo size=11 color=#000000 {NOP}")
        print("---")
    print("↺ Refresh | refresh=true color=#000000")


if __name__ == "__main__":
    main()
