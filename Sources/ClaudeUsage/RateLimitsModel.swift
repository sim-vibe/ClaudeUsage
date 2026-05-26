import Foundation
import Combine

struct RateWindow: Codable {
    let used_percentage: Int
    let resets_at: TimeInterval
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
    @Published var frameIndex: Int = 0

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
        isOnboarded = true
        startWatching()
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
