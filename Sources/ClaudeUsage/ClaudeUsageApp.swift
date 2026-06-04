import SwiftUI

@main
struct ClaudeUsageApp: App {
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
    }
}
