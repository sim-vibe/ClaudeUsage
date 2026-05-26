import Foundation

enum HookInstaller {
    static let hookScriptContent = """
    #!/bin/bash
    # Installed by Claude Usage app
    input=$(cat)

    python3 -c "
    import json, sys, os
    d = json.load(sys.stdin)
    rl = d.get('rate_limits', {})
    if not rl:
        sys.exit(0)
    path = os.path.expanduser('~/.claude/widgets/rate_limits.json')
    os.makedirs(os.path.dirname(path), exist_ok=True)
    new = json.dumps(rl, sort_keys=True)
    with open(path, 'w') as f:
        f.write(new)
    " <<< \"$input\"

    python3 -c "
    import json, sys
    d = json.load(sys.stdin)
    rl = d.get('rate_limits', {})
    fh = rl.get('five_hour', {})
    sd = rl.get('seven_day', {})
    parts = []
    if fh: parts.append(f\\\"5h:{fh.get('used_percentage',0):.0f}%\\\")
    if sd: parts.append(f\\\"7d:{sd.get('used_percentage',0):.0f}%\\\")
    print(' | '.join(parts))
    " <<< \"$input\" 2>/dev/null
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
