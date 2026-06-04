# Token Meter for Claude — Handoff

macOS menu bar app that shows Claude Code token usage (5-hour session + 7-day
weekly), reading the same rate-limit data Claude Code's `/usage` reports. This is
a native SwiftUI rewrite of an earlier SwiftBar + Python widget. **Target: Mac App Store.**

## Identity / locations

| | |
|---|---|
| Repo | `github.com/sim-vibe/ClaudeUsage` (origin/main) |
| Local path | `~/Developer/ClaudeUsage` |
| Bundle ID | `com.simvibe.ClaudeUsage` — **App Store identity, do NOT change** |
| User-facing name | "Token Meter for Claude" (short: "Token Meter") |
| Internal target/module | `ClaudeUsage` (not user-visible) |
| Copyright | `Copyright © 2026 Keyz. All rights reserved.` |
| Support email | `support@keyz.dev` (Contact Us → mailto) |

## How it works (architecture)

1. **Onboarding** — sandboxed apps can't read `~/.claude`, so the user grants it
   once via `NSOpenPanel` → security-scoped bookmark (`BookmarkManager`,
   persisted in UserDefaults). Panel opens pre-pointed at `~/.claude`; one click.
2. **Hook install** — `HookInstaller` writes `~/.claude/widgets/save_rate_limits.sh`
   (pure bash + `plutil`, **no python3** — python3 is absent on Macs without Xcode
   CLT) and sets `statusLine` in `~/.claude/settings.json`.
3. **Hook fires on every Claude Code API response**: (a) saves `rate_limits.json`,
   (b) prints `5h:X% | 7d:Y%` → shown in Claude Code's own input status line.
4. **App** reads `rate_limits.json` via `FileWatcher` + the bookmark, draws progress
   bars in a `.window`-style `MenuBarExtra`.
5. **Demo mode** (`loadDemoData`) shows sample data with no Claude Code present —
   for App Store reviewers and curious users. "Exit" returns to onboarding.

## Build & run (local, any machine)

Requires **Xcode** + **xcodegen**. The `.xcodeproj` and `build/` are gitignored and
regenerated:

```bash
brew install xcodegen
cd ~/Developer/ClaudeUsage
xcodegen generate
xcodebuild -project ClaudeUsage.xcodeproj -scheme ClaudeUsage -configuration Release \
  -derivedDataPath build \
  CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=YES CODE_SIGNING_ALLOWED=YES build
open "build/Build/Products/Release/Token Meter.app"
```

`CODE_SIGN_IDENTITY="-"` = ad-hoc "Sign to Run Locally"; sandbox + security-scoped
bookmarks work on the same machine. (First-ever Xcode use on a machine may need
`xcodebuild -runFirstLaunch`.)

To re-test onboarding after granting once, clear the saved bookmark:
```bash
defaults delete "$HOME/Library/Containers/com.simvibe.ClaudeUsage/Data/Library/Preferences/com.simvibe.ClaudeUsage" claudeDirectoryBookmark
killall cfprefsd
```

## Status — DONE

- Native rewrite, verified end-to-end on the original dev Mac.
- `plutil` hook (python3 dependency removed).
- `used_percentage` decoded as **Double** — Claude Code sends fractional values;
  Int decoding silently dropped the whole payload.
- Fully **English** UI + local time zone (`CFBundleDevelopmentRegion=en`).
- `.window` `MenuBarExtra`: progress bars render, sharp text, native hover-highlight
  rows (`MenuRowButtonStyle`), left-aligned to section titles.
- Footer: **Refresh** ("Refreshing…" feedback + "Updated h:mm:ss") / **About** /
  **Contact Us** / **Quit**.
- **About** popup: robot icon, name, version, copyright, full-width OK button.
- **Onboarding**: robot icon, 2-line copy, 1-click Allow panel, "Preview with
  sample data" + "Install Claude Code", Exit-demo back to onboarding.

## Remaining — for App Store

1. **App icon** (1024px set) — none yet; menu bar + About use the 20px robot pixel art.
2. **Signing** — the original dev Mac had **no Apple signing identity / Xcode account**.
   Upload must run on a machine signed into the Keyz/simvibe **Apple Developer account**:
   set `DEVELOPMENT_TEAM` + `CODE_SIGN_STYLE=Automatic`, archive in Xcode → upload.
3. **App Store Connect** — create app record for `com.simvibe.ClaudeUsage`,
   screenshots, description, privacy nutrition label ("no data collected").
4. **Review risk** — reviewers won't have Claude Code → demo mode covers it; add an
   App Review note ("requires Claude Code CLI, use Preview with sample data"); keep
   "for Claude" naming + a non-affiliation note (Anthropic trademark).
5. **Optional UX** — App Group container so the hook writes data the app reads with
   zero permission (drops the folder-grant dialog for reads). Needs an App Group
   entitlement tied to the Apple account.

## Machine-local (NOT in the repo)

- On the original dev Mac the old SwiftBar+Python widget was backed up to
  `~/ClaudeUsage-backup-<timestamp>/` with `RESTORE.sh`. Other machines won't have it.
- Real data requires **Claude Code installed and active** to populate `rate_limits.json`.

## Key files

| File | Role |
|---|---|
| `Sources/ClaudeUsage/ClaudeUsageApp.swift` | App entry; `.menuBarExtraStyle(.window)` |
| `Sources/ClaudeUsage/MenuBarLabel.swift` | Menu bar icon (`RobotIcon`, base64 frames) + "Start"/percent label |
| `Sources/ClaudeUsage/MenuContentView.swift` | Dropdown: sections, progress bars, footer, `MenuRowButtonStyle` |
| `Sources/ClaudeUsage/OnboardingView.swift` | Onboarding + `NSOpenPanel` grant |
| `Sources/ClaudeUsage/AboutView.swift` | About popup + its window (`AboutPanel`) |
| `Sources/ClaudeUsage/HookInstaller.swift` | Installs `plutil` hook + patches `settings.json` |
| `Sources/ClaudeUsage/BookmarkManager.swift` | Security-scoped bookmark for `~/.claude` |
| `Sources/ClaudeUsage/FileWatcher.swift` | Watches `rate_limits.json` |
| `Sources/ClaudeUsage/RateLimitsModel.swift` | State + load/refresh/demo |
| `Info.plist` / `project.yml` | Bundle config / xcodegen spec |
