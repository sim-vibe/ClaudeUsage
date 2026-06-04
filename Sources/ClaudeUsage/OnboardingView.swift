import SwiftUI
import AppKit

struct OnboardingView: View {
    @EnvironmentObject var model: RateLimitsModel
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            RobotIcon(frameIndex: 0, size: 56)

            Text("Token Meter for Claude")
                .font(.title2.bold())

            Text("See your Claude Code usage in the menu bar. Click below, then press Allow.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .font(.callout)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            if let error = errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            Button("Allow access to ~/.claude") {
                selectFolder()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Text("The .claude folder is already selected — just press Allow.")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Divider()

            // Path for users without Claude Code (and App Store reviewers).
            // The sandbox prevents detecting whether it's installed, so instead
            // of branching we offer a demo preview or a link to install it.
            VStack(spacing: 6) {
                Text("Don't have Claude Code yet?")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 12) {
                    Button("Preview with sample data") {
                        model.loadDemoData()
                    }
                    .buttonStyle(.link)
                    Link("Install Claude Code", destination: URL(string: "https://claude.com/claude-code")!)
                }
                .font(.caption)
            }
        }
        .padding(28)
        .frame(width: 340)
    }

    private func selectFolder() {
        let claudeDir = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(".claude")

        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false
        panel.title = "Token Meter — Grant Access"
        panel.message = "Press Allow to grant access to the .claude folder shown."
        panel.prompt = "Allow"
        // Open *inside* ~/.claude so the user only has to confirm — no navigating,
        // no hidden-folder hunting. Clicking Allow grants this directory.
        panel.directoryURL = claudeDir

        guard panel.runModal() == .OK else { return }

        // If the user confirmed without selecting an item, the panel authorizes the
        // directory it was showing — fall back to that.
        guard let url = panel.url ?? panel.directoryURL else {
            errorMessage = "Couldn't read the folder. Please try again."
            return
        }

        do {
            try BookmarkManager.shared.saveBookmark(for: url)
            try HookInstaller.install(in: url)
            model.onboardingCompleted()
        } catch {
            errorMessage = "Setup failed: \(error.localizedDescription)"
        }
    }
}
