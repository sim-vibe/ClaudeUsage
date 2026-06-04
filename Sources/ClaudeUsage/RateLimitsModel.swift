import Foundation
import Combine

struct RateWindow: Codable {
    // Claude Code sometimes sends a fractional percentage (e.g. 14.0000001),
    // so this must be a Double — decoding into Int would fail and the whole
    // payload would be silently dropped.
    let used_percentage: Double
    let resets_at: TimeInterval

    /// Whole-number percentage for display.
    var pct: Int { Int(used_percentage.rounded()) }
}

struct RateLimits: Codable {
    let five_hour: RateWindow?
    let seven_day: RateWindow?
}

@MainActor
final class RateLimitsModel: ObservableObject {
    @Published var rateLimits: RateLimits?
    @Published var fileAge: TimeInterval = 0
    @Published var isOnboarded: Bool = false
    @Published var isDemo: Bool = false
    @Published var frameIndex: Int = 0
    @Published var lastLoaded: Date?

    private var fileWatcher: FileWatcher?
    private var animationTimer: Timer?
    private var ageTimer: Timer?

    init() {
        isOnboarded = BookmarkManager.shared.hasBookmark
        if isOnboarded {
            startWatching()
        }
        startAnimationTimer()
        startAgeTimer()
    }

    func onboardingCompleted() {
        isDemo = false
        isOnboarded = true
        startWatching()
    }

    /// Re-read the rate limits file on demand (Refresh button).
    func refresh() {
        guard let url = rateLimitsURL() else { return }
        load(from: url)
    }

    /// Populate sample data so the UI can be evaluated without Claude Code
    /// installed (used by App Store reviewers and for a quick preview).
    func loadDemoData() {
        isDemo = true
        let now = Date().timeIntervalSince1970
        rateLimits = RateLimits(
            five_hour: RateWindow(used_percentage: 42, resets_at: now + 3 * 3600),
            seven_day: RateWindow(used_percentage: 18, resets_at: now + 4 * 24 * 3600)
        )
        fileAge = 0
        lastLoaded = Date()
    }

    /// Leave demo mode and return to the onboarding screen.
    func exitDemo() {
        isDemo = false
        rateLimits = nil
        lastLoaded = nil
    }

    private func startWatching() {
        guard let url = rateLimitsURL() else { return }
        load(from: url)
        fileWatcher = FileWatcher(url: url) { [weak self] in
            Task { @MainActor in
                guard let self, let url = self.rateLimitsURL() else { return }
                self.load(from: url)
            }
        }
    }

    private func load(from url: URL) {
        BookmarkManager.shared.withAccess {
            guard let data = try? Data(contentsOf: url),
                  let rl = try? JSONDecoder().decode(RateLimits.self, from: data) else { return }
            DispatchQueue.main.async { [weak self] in
                self?.rateLimits = rl
                let modDate = (try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date()
                self?.fileAge = Date().timeIntervalSince(modDate) / 60
                self?.lastLoaded = Date()
            }
        }
    }

    private func rateLimitsURL() -> URL? {
        BookmarkManager.shared.claudeDirectoryURL?
            .appendingPathComponent("widgets/rate_limits.json")
    }

    private func startAnimationTimer() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.frameIndex = Int(Date().timeIntervalSince1970) % 4
            }
        }
    }

    private func startAgeTimer() {
        ageTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, let url = self.rateLimitsURL() else { return }
                BookmarkManager.shared.withAccess {
                    let mod = (try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date()
                    DispatchQueue.main.async {
                        self.fileAge = Date().timeIntervalSince(mod) / 60
                    }
                }
            }
        }
    }
}
