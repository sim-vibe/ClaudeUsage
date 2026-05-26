# Token Meter for Claude

A macOS menu bar app that shows your Claude Code token usage in real time.

## Features

- **Current session** (5-hour rolling window) — percentage used and time until reset
- **Current week** (all models) — weekly aggregate and reset date
- Visual progress bars for a quick glance
- One-time setup: grant access to `~/.claude` folder and the app configures Claude Code automatically
- 100% local — no data leaves your Mac

## Requirements

- macOS 13.0 or later
- [Claude Code CLI](https://claude.ai/code) installed

## How it works

The app installs a `statusLine` hook into Claude Code's `settings.json`. After every Claude Code API response, the hook writes rate limit data to `~/.claude/widgets/rate_limits.json`, which the app reads via a file watcher.

Data comes directly from Claude Code's API response headers — the same source as Claude Code's own `/usage` command.

## Support

Open an [issue](https://github.com/sim-vibe/ClaudeUsage/issues) for bug reports or feature requests.

## Privacy

No data is collected, transmitted, or stored externally. Everything stays on your Mac.

## License

MIT
