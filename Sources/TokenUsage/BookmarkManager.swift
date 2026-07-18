import Foundation
import AppKit

final class BookmarkManager {
    static let shared = BookmarkManager()
    private let bookmarkKey = "claudeDirectoryBookmark"

    var claudeDirectoryURL: URL? {
        guard let data = UserDefaults.standard.data(forKey: bookmarkKey) else { return nil }
        var isStale = false
        guard let url = try? URL(resolvingBookmarkData: data,
                                 options: .withSecurityScope,
                                 relativeTo: nil,
                                 bookmarkDataIsStale: &isStale) else { return nil }
        if isStale {
            // Creating bookmark data requires active security-scoped access.
            let accessed = url.startAccessingSecurityScopedResource()
            try? saveBookmark(for: url)
            if accessed { url.stopAccessingSecurityScopedResource() }
        }
        return url
    }

    /// The granted directory, but only if it is actually reachable right now.
    /// A security-scoped bookmark can resolve to a URL while granting no working
    /// access (the container outlives a delete + reinstall, or the scope is
    /// revoked), so a successful read — not resolution — is the test of access.
    /// An empty-but-readable folder still qualifies.
    func accessibleClaudeDirectoryURL() -> URL? {
        guard let url = claudeDirectoryURL else { return nil }
        let accessed = url.startAccessingSecurityScopedResource()
        defer { if accessed { url.stopAccessingSecurityScopedResource() } }
        return (try? FileManager.default.contentsOfDirectory(atPath: url.path)) != nil ? url : nil
    }

    func saveBookmark(for url: URL) throws {
        let data = try url.bookmarkData(options: .withSecurityScope,
                                        includingResourceValuesForKeys: nil,
                                        relativeTo: nil)
        UserDefaults.standard.set(data, forKey: bookmarkKey)
    }

    func clearBookmark() {
        UserDefaults.standard.removeObject(forKey: bookmarkKey)
    }

    func withAccess(_ block: () -> Void) {
        guard let url = claudeDirectoryURL else { return }
        let accessed = url.startAccessingSecurityScopedResource()
        block()
        if accessed { url.stopAccessingSecurityScopedResource() }
    }

    /// Begin long-lived security-scoped access for continuous work (e.g. a file
    /// watcher's `open()`), balanced by `endAccess`. Returns the URL access was
    /// started on, or nil if there's no bookmark / access couldn't be started.
    func beginAccess() -> URL? {
        guard let url = claudeDirectoryURL else { return nil }
        return url.startAccessingSecurityScopedResource() ? url : nil
    }

    func endAccess(_ url: URL) {
        url.stopAccessingSecurityScopedResource()
    }
}
