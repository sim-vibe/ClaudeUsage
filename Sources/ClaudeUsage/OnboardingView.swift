import SwiftUI
import AppKit
import Darwin

struct OnboardingView: View {
    @EnvironmentObject var model: RateLimitsModel
    @State private var errorMessage: String?
    @State private var isInstalling = false

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 36))
                .foregroundStyle(.tint)
                .padding(.top, 4)

            VStack(spacing: 4) {
                Text("Token Meter for Claude")
                    .font(.headline)
                Text("Track your Claude Code usage in the menu bar.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 10) {
                InfoRow(icon: "folder", text: "Reads usage data from your ~/.claude folder")
                InfoRow(icon: "wand.and.stars", text: "Installs a small status-line hook (one-time)")
                InfoRow(icon: "lock.shield", text: "Everything stays on your Mac")
            }
            .font(.callout)
            .padding(.vertical, 4)

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
                    Text(isInstalling ? "Setting up…" : "Grant folder access")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isInstalling)

            Text("Requires Claude Code CLI · One-time setup")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
        .frame(width: 320)
    }

    private func realHomeDirectory() -> URL {
        if let pw = getpwuid(getuid()), let cstr = pw.pointee.pw_dir {
            return URL(fileURLWithPath: String(cString: cstr))
        }
        return URL(fileURLWithPath: NSHomeDirectory())
    }

    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Select your Claude Code config folder (~/.claude)."
        panel.prompt = "Allow"
        panel.showsHiddenFiles = true
        panel.directoryURL = realHomeDirectory().appendingPathComponent(".claude")

        guard panel.runModal() == .OK, let url = panel.url else { return }

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
                    BookmarkManager.shared.clearBookmark()
                    throw error
                }
            } catch {
                isInstalling = false
                errorMessage = error.localizedDescription
            }
        }
    }
}

private struct InfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.tint)
                .frame(width: 18, alignment: .center)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }
}
