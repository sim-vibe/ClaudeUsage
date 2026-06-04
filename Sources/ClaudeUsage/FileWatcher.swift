import Foundation

/// Watches the directory containing `url` and fires `onChange` when its contents
/// change. Two things make this reliable in a sandboxed app:
///
///  1. **Security-scoped access is held for the watcher's lifetime.** The sandbox
///     only lets us `open()` inside `~/.claude` while access is active; the
///     transient `withAccess { }` used for reads closes it immediately, so a
///     watcher opened outside it would get EPERM and never establish. We keep
///     access open from `start()` until `deinit`.
///  2. **We watch the parent directory, not the file.** The hook updates
///     `rate_limits.json` via `mv tmp rate_limits.json`, which atomically swaps
///     the file's inode. A file-level vnode watch can miss that (the watched
///     inode is unlinked); the directory's inode is stable and sees the entry
///     change as a write.
final class FileWatcher {
    private let watchDir: URL
    private let onChange: () -> Void
    private var source: DispatchSourceFileSystemObject?
    private var scopedURL: URL?

    init(url: URL, onChange: @escaping () -> Void) {
        self.watchDir = url.deletingLastPathComponent()
        self.onChange = onChange
        start()
    }

    private func start() {
        // Hold security-scoped access so open() succeeds in the sandbox.
        if scopedURL == nil { scopedURL = BookmarkManager.shared.beginAccess() }

        let fd = open(watchDir.path, O_EVTONLY)
        guard fd >= 0 else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.start()
            }
            return
        }
        let src = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .delete, .rename],
            queue: .main
        )
        src.setEventHandler { [weak self] in
            guard let self else { return }
            let events = src.data
            self.onChange()
            // If the directory itself was removed/renamed, re-establish on the new one.
            if events.contains(.delete) || events.contains(.rename) {
                src.cancel()
                self.start()
            }
        }
        src.setCancelHandler { close(fd) }
        src.resume()
        self.source = src
    }

    deinit {
        source?.cancel()
        if let url = scopedURL { BookmarkManager.shared.endAccess(url) }
    }
}
