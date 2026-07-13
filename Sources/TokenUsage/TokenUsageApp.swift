import SwiftUI
import AppKit

@main
struct TokenUsageApp: App {
    @StateObject private var model = RateLimitsModel()

    var body: some Scene {
        MenuBarExtra {
            MenuContentView()
                .environmentObject(model)
        } label: {
            MenuBarLabel()
                .environmentObject(model)
        }
        // .window renders the dropdown as a real SwiftUI view (not menu items),
        // so progress bars draw and text shows at full opacity instead of the
        // dimmed "disabled menu item" look.
        .menuBarExtraStyle(.window)
        .commands {
            // Replace SwiftUI's default "Help isn't available…" item with a
            // Contact Support link. (macOS still adds the Help search field.)
            CommandGroup(replacing: .help) {
                Button("Contact Support") {
                    if let url = URL(string: "https://keyz.dev/contact/") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
    }
}
