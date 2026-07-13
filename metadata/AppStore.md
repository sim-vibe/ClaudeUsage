# App Store Metadata — Token Usage for Claude

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
5. 🟡 **Subtitle** — CHANGE `Claude Code usage monitor` → `Claude usage menu bar monitor`
   (lead with the exact priority phrase "Claude usage"; see below).
6. 🟢 **Secondary category** — optional: add **Productivity**.
7. 🟢 **Promotional Text** — current copy is good; keep.
8. ⚠️ **Support contact email** — `ccusage@icloud.com` → `support@keyz.dev`.
   (Not on the App Information page; likely under Agreements/contacts or the
   App Review contact — locate before submitting.)

---

## App Name — limit 30

```
Token Usage for Claude
```
`22/30` ✓ — matches `CFBundleDisplayName`. Do **not** change.

> ### 🔎 How App Store search actually indexes (read first)
> Apple indexes **only three fields** for search: **app name**, **subtitle**, and the
> **keywords field**. The **description and promotional text are NOT indexed for search**
> — they only affect conversion *after* a user finds the listing. So all discovery SEO
> lives in name + subtitle + keywords; Apple unions the words across the three and also
> rewards exact-phrase + early-position matches.
>
> **Target queries (per product decision): `claude` and `claude usage`.** The app name
> `Token Usage for Claude` already carries *both* target words in the highest-weight
> field, so "claude usage" is matched at the word level out of the box. The subtitle is
> then tuned to surface the **exact adjacent phrase "Claude usage" first**, which is the
> strongest ranking signal for that query.

## Subtitle — limit 30  →  CHANGE

**Recommended (replace current `Claude Code usage monitor`):**
```
Claude usage menu bar monitor
```
`29/30` ✓ — opens with the exact target phrase **"Claude usage"** (adjacent + first =
best signal for the priority query), then adds `menu` + `bar` + `monitor`. Drops `code`
vs the old subtitle — recovered in the keywords field below (most users search `claude`
/ `claude usage`, not `claude code`, so spend the highest-weight field on the priority
phrase).

## Keywords — limit 100 (comma-separated, NO spaces after commas)

**Current (live):** `claude,anthropic,token,usage,menu bar,ai monitor,claude code,developer,rate limit` `81/100`

Problems with the live set:
- `claude`, `anthropic`, `claude code` → **third-party trademarks as standalone
  keywords** = common rejection (Guideline 2.3.7 / 5.2.5). Remove.
- `claude`, `token`, `usage` → already in the **app name** (and `usage` again in the
  subtitle), which Apple indexes separately → duplicates, wasted space.
- `ai monitor` → a fixed phrase; Apple auto-combines standalone words, so
  `AI` + `monitor` as separate terms reaches more queries.

**Recommended (replace with this):**
```
code,rate limit,tracker,quota,menubar,AI,CLI,developer,statusline,session,widget,context
```
`95/100` ✓ — no trademarks, no duplication with name/subtitle. `code` here recombines
with `claude` from the name to still cover **"claude code"**; `menubar` (no space)
catches the unspaced search variant of the subtitle's "menu bar".

> Keyword principle: Apple already indexes every word in the **name** (token, usage,
> claude) and **subtitle** (claude, usage, menu, bar, monitor) — search unions name +
> subtitle + keywords. Never repeat those words in the keywords field.
>
> **On the top-priority `claude` query:** "claude" is intentionally kept OUT of the
> keywords field. It already sits in the **app name** — the single highest-weight,
> already-indexed placement — so it ranks for "claude" without a keyword entry. Adding
> standalone `claude` to keywords adds the 2.3.7/5.2.5 trademark-rejection risk for only
> marginal weight gain. If you decide the "claude" rank is worth that risk, the lowest-
> risk lever is the subtitle/description phrasing (descriptive use), not a bare keyword.

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
Token Usage for Claude shows your Claude Code token usage directly in your Mac menu bar — no tab switching, no commands to run.

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
Token Usage for Claude is an independent app and is not affiliated with, endorsed by, or sponsored by Anthropic. "Claude" is a trademark of Anthropic, PBC, used here to describe compatibility.
```
≈ `1050/4000` ✓ — additions vs live are **bold-italic** in the action list above.

## What's New (release notes) — limit 4000

For the **1.0** initial release:
```
Initial release. Token Usage for Claude shows your Claude Code session and weekly token usage right in the menu bar.
```

For **1.0.2** (build 7):
```
The app icon now adopts the new macOS icon appearance, with light, dark, and tinted variants.
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

Token Usage for Claude is an independent app, not affiliated with Anthropic. "Claude" is used only to describe compatibility.
```

## Screenshots

**Final set committed** under `metadata/screenshots/` (dark mode, 1280×800), source +
regeneration notes in `metadata/screenshots/src/`. Replace the 2 currently in ASC with
these 3, in order:
1. `01_usage.png` — hero + live usage dropdown (the money shot)
2. `02_onboarding.png` — one-click setup / onboarding card
3. `03_menubar.png` — menu-bar context (chip + open dropdown)

Dark set chosen on purpose: matches the app's real dark-mode appearance and suits the
Claude Code audience. macOS accepts 1280×800 / 1440×900 / 2560×1600 / 2880×1800.
(A light alternate of shots 1–2 also exists locally if ever needed.)

---

## Account migration (personal → organization) — watch items

The personal account record (Team **Gwangseop Shim**, app ID `6773230249`) must reach
the organization account before/at submission. Implications to verify after migration:
- **App Transfer** may be needed; metadata + screenshots follow the transfer, but
  **price/agreements/banking** are re-set on the receiving account.
- **Copyright / seller name** should become the org's legal entity (likely "Keyz").
- **`DEVELOPMENT_TEAM`** in signing changes to the org's Team ID — re-select in Xcode.
