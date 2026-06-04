# App Store Metadata — Token Meter for Claude

Source of truth for the Mac App Store listing copy. Paste into App Store Connect
(app ID `6773230249`). Character counts are App Store hard limits — stay at or
under them. Locale: **en** (`CFBundleDevelopmentRegion=en`).

> **Status:** v3 — reconciled against the full live ASC copy captured **2026-06-05**
> (App Information + version page).
> **Note:** App Store Connect's character counters show *remaining* characters, not used.

---

## Changes to make in ASC (action list, by priority)

1. 🔴 **Keywords** — replace entirely (remove trademark + duplicate terms). See below.
2. 🟡 **Description** — add the non-affiliation note + the "Preview with sample data" line.
3. 🟡 **Copyright** — reconcile `Gwangseop Shim` vs `Keyz`; align to the org's legal
   entity once the personal→organization account migration completes.
4. 🟡 **Content Rights** (App Information) — currently NOT set up. Set to "does not
   contain, show, or access third-party content" (the app shows only the user's own
   local usage data). Required before submission.
5. 🟢 **Subtitle** — KEEP current `Claude Code usage monitor` (good — see below).
6. 🟢 **Secondary category** — optional: add **Productivity**.
7. 🟢 **Promotional Text** — current copy is good; keep.
8. ⚠️ **Support contact email** — `ccusage@icloud.com` → `support@keyz.dev`.
   (Not on the App Information page; likely under Agreements/contacts or the
   App Review contact — locate before submitting.)

---

## App Name — limit 30

```
Token Meter for Claude
```
`22/30` ✓ — matches `CFBundleDisplayName`. Do **not** change.

## Subtitle — limit 30  →  KEEP CURRENT

**Current (live) — keep:**
```
Claude Code usage monitor
```
`25/30` ✓ — indexes claude, code, usage, monitor. This is the right call: "token" is
already in the **app name**, so spending the subtitle on "monitor" (a search term the
name/keywords don't otherwise cover) is more efficient than repeating "token".

## Keywords — limit 100 (comma-separated, NO spaces after commas)

**Current (live):** `claude,anthropic,token,usage,menu bar,ai monitor,claude code,developer,rate limit` `81/100`

Problems with the live set:
- `claude`, `anthropic`, `claude code` → **third-party trademarks as standalone
  keywords** = common rejection (Guideline 2.3.7 / 5.2.5). Remove.
- `claude`, `token` → already in the **app name**, which Apple indexes separately →
  duplicates, wasted space.
- `ai monitor` → a fixed phrase; Apple auto-combines standalone words, so
  `AI` + `monitor` as separate terms reaches more queries.

**Recommended (replace with this):**
```
rate limit,menu bar,menubar,tracker,quota,AI,CLI,developer,statusline,session,coding,widget,context
```
`99/100` ✓ — no trademarks, no duplication with name/subtitle.

> Keyword principle: Apple already indexes every word in the **name** (token, meter,
> claude) and **subtitle** (claude, code, usage, monitor) — search uses name + subtitle
> + keywords combined. Never repeat those 6 words here. Note `monitor` is intentionally
> dropped from keywords because it's now covered by the subtitle; the freed space goes
> to `widget` + `context`.

## Promotional Text — limit 170 (editable anytime, NO review needed)

**Current (live) — keep:**
```
Monitor your Claude Code token usage right from the menu bar. See your 5-hour session and weekly limits in real time — no setup hassle.
```
`135/170` ✓ — punchy ("no setup hassle"). Fine as-is.

## Description — limit 4000

Live copy is strong. Only two adds: the demo-mode line (helps reviewers) and the
non-affiliation footer (trademark safety). Final:
```
Token Meter for Claude shows your Claude Code token usage directly in your Mac menu bar — no tab switching, no commands to run.

WHAT IT SHOWS
• Current session (5-hour rolling window) — percentage used and time until reset
• Current week (all models) — weekly aggregate and reset date
• Visual progress bars for a quick glance

HOW IT WORKS
1. Install and launch the app
2. Grant access to your ~/.claude folder (one-time, click-to-confirm)
3. The app automatically configures Claude Code and starts monitoring

Want to try it first? Choose "Preview with sample data" to explore the full interface — no Claude Code required.

Data comes directly from Claude Code's API response headers — the exact same source as Claude Code's own /usage command. No estimation, no drift.

PRIVACY
No data is collected, transmitted, or stored externally. Everything stays on your Mac.

REQUIREMENTS
• macOS 13.0 or later
• Claude Code CLI installed (claude.ai/code)

—
Token Meter for Claude is an independent app and is not affiliated with, endorsed by, or sponsored by Anthropic. "Claude" is a trademark of Anthropic, PBC, used here to describe compatibility.
```
≈ `1050/4000` ✓ — additions vs live are **bold-italic** in the action list above.

## What's New (release notes) — limit 4000

For the **1.0** initial release:
```
Initial release. Token Meter shows your Claude Code session and weekly token usage right in the menu bar.
```

---

## Other ASC fields — verify, don't optimize

| Field | Live value | Note |
|---|---|---|
| Version | `1.0` | OK |
| Bundle ID | `com.simvibe.ClaudeUsage` | OK (do not change) |
| SKU | `claude-usage-macos` | OK |
| Primary category | Developer Tools | OK |
| Secondary category | *(empty)* | optional: add **Productivity** for reach |
| Content Rights | *(not set up)* | ⚠️ set: "no third-party content" — required |
| Age rating | 4+ | OK |
| Price | Free | OK |
| Privacy | "Data Not Collected" (published) | OK |
| Support URL | `https://github.com/sim-vibe/ClaudeUsage` | OK |
| Marketing URL | *(empty)* | optional |
| Support contact email | `ccusage@icloud.com` | ⚠️ change → `support@keyz.dev` |
| Copyright | `© 2026 Gwangseop Shim` | ⚠️ change → **`© 2026 Keyz`** (decided) |

## App Review note (paste into "Notes for Review")

```
This app displays Claude Code CLI token-usage data and requires the Claude Code CLI to be installed to show live data. Reviewers without Claude Code installed can tap "Preview with sample data" on the onboarding screen to see the full interface with demo data.

Token Meter is an independent app, not affiliated with Anthropic. "Claude" is used only to describe compatibility.
```

## Screenshots

Currently 2 in ASC. macOS sizes: 1280×800 / 1440×900 / 2560×1600 / 2880×1800.
Priority set:
1. Menu bar dropdown with both progress bars populated (the money shot)
2. Onboarding / "Preview with sample data" screen
3. *(optional)* About panel or the menu bar item in context

---

## Account migration (personal → organization) — watch items

The personal account record (Team **Gwangseop Shim**, app ID `6773230249`) must reach
the organization account before/at submission. Implications to verify after migration:
- **App Transfer** may be needed; metadata + screenshots follow the transfer, but
  **price/agreements/banking** are re-set on the receiving account.
- **Copyright / seller name** should become the org's legal entity (likely "Keyz").
- **`DEVELOPMENT_TEAM`** in signing changes to the org's Team ID — re-select in Xcode.
