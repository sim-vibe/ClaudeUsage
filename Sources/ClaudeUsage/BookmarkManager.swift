import Foundation
import AppKit

final class BookmarkManager {
    static let shared = BookmarkManager()
    private let bookmarkKey = "claudeDirectoryBookmark"

    var hasBookmark: Bool {
        UserDefaults.standard.data(forKey: bookmarkKey) != nil
    }

    var claudeDirectoryURL: URL? {
        guard let data = UserDefaults.standard.data(forKey: bookmarkKey) else { return nil }
        var isStale = false
        return try? URL(resolvingBookmarkData: data,
                        options: .withSecurityScope,
                        relativeTo: nil,
                        bookmarkDataIsStale: &isStale)
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
