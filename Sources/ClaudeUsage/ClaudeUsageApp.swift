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
    }
}
