import SwiftUI
import AppKit

/// Simple app-info popup styled like a standard "About" box, with an OK button.
struct AboutView: View {
    var onOK: () -> Void

    private var version: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        return v
    }

    private var copyright: String {
        Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as? String ?? ""
    }

    var body: some View {
        VStack(spacing: 12) {
            RobotIcon(frameIndex: 0, size: 64)

            Text("Token Meter for Claude")
                .font(.headline)

            Text("Version \(version)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !copyright.isEmpty {
                Text(copyright)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }

            Button(action: onOK) {
                Text("OK")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .keyboardShortcut(.defaultAction)
            .padding(.top, 4)
        }
        .padding(24)
        .frame(width: 280)
    }
}

/// Presents `AboutView` in a clean, chrome-less floating window (no traffic
/// lights), centered on screen — closeable via its OK button.
enum AboutPanel {
    private static var window: NSWindow?

    static func show() {
        NSApp.activate(ignoringOtherApps: true)

        if let existing = window {
            existing.center()
            existing.makeKeyAndOrderFront(nil)
            return
        }

        let hosting = NSHostingController(rootView: AboutView(onOK: { close() }))
        let w = NSWindow(contentViewController: hosting)
        w.styleMask = [.titled, .fullSizeContentView]
        w.titleVisibility = .hidden
        w.titlebarAppearsTransparent = true
        w.isMovableByWindowBackground = true
        w.standardWindowButton(.closeButton)?.isHidden = true
        w.standardWindowButton(.miniaturizeButton)?.isHidden = true
        w.standardWindowButton(.zoomButton)?.isHidden = true
        w.isReleasedWhenClosed = false
        // Lock the window to the SwiftUI content's size *before* showing, so it
        // doesn't appear at a guessed size and then snap/jitter to fit. Disable
        // the open animation for the same reason, then center the final size.
        w.animationBehavior = .none
        hosting.view.layoutSubtreeIfNeeded()
        w.setContentSize(hosting.view.fittingSize)
        w.center()
        window = w
        w.makeKeyAndOrderFront(nil)
    }

    static func close() {
        window?.close()
    }
}
