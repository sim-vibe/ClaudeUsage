# App Store screenshots — source

Dark-mode set for the Mac App Store listing. Rendered from HTML/CSS via a headless
browser at exactly **1280×800** (an accepted macOS screenshot size).

Faithful mockups of the real app UI (dark vibrancy card, monospace usage rows, blue
progress bars, full footer Refresh/About/Contact Us/Quit, the real menu-bar label
`🤖 28% · 69%w`, and the onboarding card). The robot glyph (`robot_glyph.png`) was
lifted from a real onboarding capture and background-keyed to transparent.

## Regenerate

```bash
cd metadata/screenshots/src
python3 -m http.server 8731    # serve this dir (file:// is blocked by the browser)
# then render each at viewport 1280x800 and screenshot:
#   01_usage.html  02_onboarding.html  03_menubar.html
```

Render with any headless browser at viewport 1280×800, full-viewport screenshot,
and save the three PNGs one directory up (`../01_usage.png`, etc.).

## Notes
- Dark set chosen deliberately: the app adapts to system dark mode (semantic
  `Color.primary`/`.secondary` + the default menu-bar window material), so these match
  the real app, and the Claude Code audience skews dark mode.
- Edit copy/colors directly in the HTML and re-render. Accent teal `#3fe3cc`,
  background deep-teal→navy gradient, system blue `#0a84ff` for progress.
