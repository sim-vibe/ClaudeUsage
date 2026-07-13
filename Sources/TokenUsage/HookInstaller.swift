import Foundation

enum HookInstaller {
    // Uses `plutil` only — built into every macOS install, so no python3
    // (which is absent on Macs without Xcode Command Line Tools) is required.
    static let hookScriptContent = """
    #!/bin/bash
    # Installed by Token Usage for Claude
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

    private static let statusLineEntry: [String: Any] = [
        "type": "command",
        "command": "~/.claude/widgets/save_rate_limits.sh"
    ]

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
        var settings = readSettings(at: settingsURL)
        settings["statusLine"] = statusLineEntry
        try writeSettings(settings, to: settingsURL)
    }

    /// Re-verify the integration and restore only what's missing. The container
    /// (bookmark, UserDefaults) can outlive both the app and the user's ~/.claude
    /// contents, so "bookmark resolves" doesn't imply the hook is still installed.
    /// Best-effort and safe to run on every launch. Unlike `install`, a statusLine
    /// the user pointed at a different command is left untouched.
    static func repair(in claudeDir: URL) {
        let accessed = claudeDir.startAccessingSecurityScopedResource()
        defer { if accessed { claudeDir.stopAccessingSecurityScopedResource() } }

        let widgetsDir = claudeDir.appendingPathComponent("widgets")
        let hookURL = widgetsDir.appendingPathComponent("save_rate_limits.sh")
        if (try? String(contentsOf: hookURL, encoding: .utf8)) != hookScriptContent {
            try? FileManager.default.createDirectory(at: widgetsDir, withIntermediateDirectories: true)
            try? hookScriptContent.write(to: hookURL, atomically: true, encoding: .utf8)
        }
        try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: hookURL.path)

        let settingsURL = claudeDir.appendingPathComponent("settings.json")
        var settings = readSettings(at: settingsURL)
        if settings["statusLine"] == nil {
            settings["statusLine"] = statusLineEntry
            try? writeSettings(settings, to: settingsURL)
        }
    }

    private static func readSettings(at url: URL) -> [String: Any] {
        guard let data = try? Data(contentsOf: url),
              let existing = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return [:]
        }
        return existing
    }

    private static func writeSettings(_ settings: [String: Any], to url: URL) throws {
        let data = try JSONSerialization.data(withJSONObject: settings, options: [.prettyPrinted, .sortedKeys])
        try data.write(to: url, options: .atomic)
    }
}
