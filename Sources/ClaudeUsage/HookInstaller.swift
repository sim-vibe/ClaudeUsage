import Foundation

enum HookInstaller {
    // Uses `plutil` only — built into every macOS install, so no python3
    // (which is absent on Macs without Xcode Command Line Tools) is required.
    static let hookScriptContent = """
    #!/bin/bash
    # Installed by Token Meter for Claude
    input=$(cat)
    widgets="$HOME/.claude/widgets"
    mkdir -p "$widgets"

    # Save the rate_limits object to a file (atomic; only on success).
    tmp=$(mktemp)
    if printf '%s' "$input" | plutil -extract rate_limits json -o "$tmp" - 2>/dev/null; then
        mv "$tmp" "$widgets/rate_limits.json"
    else
        rm -f "$tmp"
    fi

    # Emit the Claude Code status line (e.g. "5h:11% | 7d:16%").
    fh=$(printf '%s' "$input" | plutil -extract rate_limits.five_hour.used_percentage raw -o - - 2>/dev/null)
    sd=$(printf '%s' "$input" | plutil -extract rate_limits.seven_day.used_percentage raw -o - - 2>/dev/null)
    line=""
    [ -n "$fh" ] && line="5h:${fh%.*}%"
    if [ -n "$sd" ]; then
        [ -n "$line" ] && line="$line | "
        line="${line}7d:${sd%.*}%"
    fi
    echo "$line"
    """

    static func install(in claudeDir: URL) throws {
        let accessed = claudeDir.startAccessingSecurityScopedResource()
        defer { if accessed { claudeDir.stopAccessingSecurityScopedResource() } }

        // 1. Create widgets dir
        let widgetsDir = claudeDir.appendingPathComponent("widgets")
        try FileManager.default.createDirectory(at: widgetsDir, withIntermediateDirectories: true)

        // 2. Write hook script
        let hookURL = widgetsDir.appendingPathComponent("save_rate_limits.sh")
        try hookScriptContent.write(to: hookURL, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: hookURL.path)

        // 3. Patch settings.json
        let settingsURL = claudeDir.appendingPathComponent("settings.json")
        var settings: [String: Any] = [:]
        if let data = try? Data(contentsOf: settingsURL),
           let existing = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            settings = existing
        }
        settings["statusLine"] = [
            "type": "command",
            "command": "~/.claude/widgets/save_rate_limits.sh"
        ]
        let updated = try JSONSerialization.data(withJSONObject: settings, options: [.prettyPrinted, .sortedKeys])
        try updated.write(to: settingsURL, options: .atomic)
    }
}
