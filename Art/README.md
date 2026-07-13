# Art

Source art for the app. Nothing here is a build input — the build reads only
`Sources/TokenUsage/AppIcon.icon` (app icon) and the base64 blobs in
`MenuBarLabel.swift` (menu bar icon).

| File | Used by |
|---|---|
| `robot/robot_frame_{0-3}.png` | Menu bar walk cycle, 20×20. Embedded as base64 in `Sources/TokenUsage/MenuBarLabel.swift` — editing a PNG here has no effect until you re-embed it. |

The app icon's robot layer (`AppIcon.icon/Assets/robot_frame_0_1024.png`) is a
1024px redraw of frame 0. Edit it in Icon Composer, not here.
