# Token Meter for Claude — Handoff

macOS menu bar app that shows Claude Code token usage (5-hour session + 7-day
weekly), reading the same rate-limit data Claude Code's `/usage` reports. This is
a native SwiftUI rewrite of an earlier SwiftBar + Python widget. **Target: Mac App Store.**

## Identity / locations

| | |
|---|---|
| Repo | `github.com/sim-vibe/ClaudeUsage` (origin/main) |
| Local path | `~/Developer/ClaudeUsage` |
| App Store Connect | Apple app ID **`6773230249`** · Team **Gwangseop Shim** (personal account) |
| Bundle ID | `com.simvibe.ClaudeUsage` — **App Store identity, do NOT change** (also keyed to the saved folder-access bookmark) |
| User-facing name | "Token Meter for Claude" (`CFBundleDisplayName` + App Store listing name) |
| Bundle / executable / `PRODUCT_NAME` | **`Token Meter`** → bundle is `Token Meter.app`. No "ClaudeUsage" string is user-visible. |
| Internal Xcode target / scheme | `ClaudeUsage` (dev-only, not in the bundle, not user-visible) |
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

Requires **Xcode** + **xcodegen**. `project.yml` is configured for **App Store**
distribution (`CODE_SIGN_STYLE=Automatic`, `ENABLE_HARDENED_RUNTIME=YES`,
`ASSETCATALOG_COMPILER_APPICON_NAME=AppIcon`), so a **local** build on a machine
with no Apple account must override those at the CLI:

```bash
brew install xcodegen
cd ~/Developer/ClaudeUsage
xcodegen generate
xcodebuild -project ClaudeUsage.xcodeproj -scheme ClaudeUsage -configuration Debug \
  -derivedDataPath build \
  CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=YES \
  ENABLE_HARDENED_RUNTIME=NO build
open "build/Build/Products/Debug/Token Meter.app"
```

`CODE_SIGN_IDENTITY="-"` = ad-hoc "Sign to Run Locally"; sandbox + security-scoped
bookmarks work on the same machine. On a machine **with** the Apple account, drop
the overrides and just set `DEVELOPMENT_TEAM` (see "Remaining"). (First-ever Xcode
use on a machine may need `xcodebuild -runFirstLaunch`.)

To re-test onboarding after granting once, clear the saved bookmark:
```bash
defaults delete "$HOME/Library/Containers/com.simvibe.ClaudeUsage/Data/Library/Preferences/com.simvibe.ClaudeUsage" claudeDirectoryBookmark
killall cfprefsd
```

## Status — DONE

- Native rewrite, verified end-to-end on the original dev Mac (build + install +
  live data + auto-refresh). Latest commit `b1d9f17`, pushed to `origin/main`.
- **Merge resolved** — the repo had diverged into two parallel branches:
  *(a)* App Store assets/config + app icon (`Assets.xcassets/AppIcon.appiconset`,
  Automatic signing, hardened runtime), and *(b)* the native UI / plutil / demo
  rewrite. Merged taking the better side per concern; `.xcodeproj` is now
  gitignored (xcodegen is the single source of truth).
- **App icon** — full 1024px icon set is committed under
  `Sources/ClaudeUsage/Assets.xcassets/AppIcon.appiconset` and bundled
  (`AppIcon.icns` + `Assets.car`). *(Was the #1 remaining item — now done.)*
- **Name unified** — `PRODUCT_NAME = "Token Meter"`; no "ClaudeUsage" string is
  user-visible. Display/App Store name stays "Token Meter for Claude".
- `plutil` hook (python3 dependency removed).
- `used_percentage` decoded as **Double** — Claude Code sends fractional values;
  Int decoding silently dropped the whole payload.
- Fully **English** UI + local time zone (`CFBundleDevelopmentRegion=en`).
- `.window` `MenuBarExtra`: progress bars render, sharp text, native hover-highlight
  rows (`MenuRowButtonStyle`), left-aligned to section titles.
- Footer: **Refresh** ("Refreshing…" feedback + "Updated h:mm:ss") / **About** /
  **Contact Us** / **Quit**.
- **About** popup: robot icon, name, version, copyright, full-width OK button;
  window sized to content (`fittingSize`) with `animationBehavior = .none` so it
  opens centered with **no jitter**.
- **Onboarding**: robot icon, 2-line copy, 1-click Allow panel (uses
  `realHomeDirectory()` via `getpwuid` so it points at the *real* `~/.claude`, not
  the sandbox container; rolls back the bookmark on install failure), "Preview with
  sample data" + "Install Claude Code", Exit-demo back to onboarding.
- **`FileWatcher`** auto-refresh: the hook updates `rate_limits.json` via `mv`
  (atomic inode swap). Two things are required for live updates in the sandbox and
  both are in place: (1) hold security-scoped access for the watcher's lifetime
  (`BookmarkManager.beginAccess/endAccess`) — otherwise `open(O_EVTONLY)` gets EPERM
  and the watch never establishes (symptom: data loads once at launch, then only
  updates on manual Refresh); (2) watch the **parent directory** (stable inode),
  not the file, so the atomic replace is seen as a directory write.

## Remaining — for App Store

Must be done on a machine signed into the Keyz/simvibe **Apple Developer account**
(the original dev Mac had none). The app icon and signing config already exist in
the repo, so the work is now mostly account-side:

**App Store Connect record already set up** (app ID `6773230249`): name/subtitle/
description/keywords, 2 screenshots, support+marketing+privacy URLs, price (free,
175 countries), privacy ("no data collected", published), age 4+, category
Developer Tools. So only the build upload remains:

1. **Signing** — open in Xcode, select Team **Gwangseop Shim** so `DEVELOPMENT_TEAM`
   is set. The project is already `CODE_SIGN_STYLE=Automatic` +
   `ENABLE_HARDENED_RUNTIME=YES`, so no project edits needed.
2. **Archive → Distribute → App Store Connect → Upload** (Release builds automatically).
3. **Attach the build for review** — after upload (~5–10 min):
   `https://appstoreconnect.apple.com/apps/6773230249/distribution/macos/version/inflight`
   → pick the build in the **Build** section → **Submit for Review**.
4. **Review risk** — reviewers won't have Claude Code → demo mode covers it; the App
   Review note should say "requires Claude Code CLI; use *Preview with sample data*";
   keep "for Claude" naming + a non-affiliation note (Anthropic trademark).
5. **Optional UX** — App Group container so the hook writes data the app reads with
   zero permission (drops the folder-grant dialog for reads). Needs an App Group
   entitlement tied to the Apple account.

> **Support email = `support@keyz.dev`** (decided). The app's Contact Us already
> uses it; update the App Store Connect support contact (currently
> `ccusage@icloud.com`) to match before submitting.

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
| `Sources/ClaudeUsage/BookmarkManager.swift` | Security-scoped bookmark for `~/.claude` (`withAccess` for reads; `beginAccess`/`endAccess` for the long-lived watcher) |
| `Sources/ClaudeUsage/FileWatcher.swift` | Watches the `widgets/` dir (holds access) → live updates |
| `Sources/ClaudeUsage/RateLimitsModel.swift` | State + load/refresh/demo |
| `Sources/ClaudeUsage/Assets.xcassets/AppIcon.appiconset` | App icon (1024px set; `AppIcon`) |
| `Info.plist` / `project.yml` | Bundle config / xcodegen spec (`.xcodeproj` is generated, gitignored) |
