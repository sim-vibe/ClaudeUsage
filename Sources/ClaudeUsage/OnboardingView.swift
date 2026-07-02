import SwiftUI
import AppKit
import Darwin

struct OnboardingView: View {
    @EnvironmentObject var model: RateLimitsModel
    @State private var errorMessage: String?
    @State private var isInstalling = false

    var body: some View {
        VStack(spacing: 16) {
            RobotIcon(frameIndex: 0, size: 56)

            Text("Token Usage for Claude")
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
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                selectFolder()
            } label: {
                HStack(spacing: 6) {
                    if isInstalling {
                        ProgressView().controlSize(.small)
                    }
                    Text(isInstalling ? "Setting up…" : "Allow access to ~/.claude")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isInstalling)

            Text("The .claude folder is already selected — just press Allow.")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Divider()

            // Path for users without Claude Code (and App Store reviewers).
            // The sandbox prevents detecting whether it's installed, so instead
            // of branching we offer a demo preview or a link to install it.
            VStack(spacing: 8) {
                Text("Don't have Claude Code yet?")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button("Preview with sample data") {
                    model.loadDemoData()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                Link("Install Claude Code", destination: URL(string: "https://claude.com/claude-code")!)
                    .font(.caption)
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
        .frame(width: 320)
    }

    /// Resolve the user's REAL home directory. In a sandboxed app
    /// `NSHomeDirectory()` returns the container path, so we ask the password
    /// database for the actual home to point the panel at the right ~/.claude.
    private func realHomeDirectory() -> URL {
        if let pw = getpwuid(getuid()), let cstr = pw.pointee.pw_dir {
            return URL(fileURLWithPath: String(cString: cstr))
        }
        return URL(fileURLWithPath: NSHomeDirectory())
    }

    private func selectFolder() {
        let claudeDir = realHomeDirectory().appendingPathComponent(".claude")

        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false
        panel.title = "Token Usage — Grant Access"
        panel.message = "Press Allow to grant access to the .claude folder shown."
        panel.prompt = "Allow"
        panel.showsHiddenFiles = true
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

        errorMessage = nil
        isInstalling = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            do {
                try BookmarkManager.shared.saveBookmark(for: url)
                do {
                    try HookInstaller.install(in: url)
                    isInstalling = false
                    model.onboardingCompleted()
                } catch {
                    // Roll back the bookmark so the next attempt starts clean.
                    BookmarkManager.shared.clearBookmark()
                    throw error
                }
            } catch {
                isInstalling = false
                errorMessage = "Setup failed: \(error.localizedDescription)"
            }
        }
    }
}
