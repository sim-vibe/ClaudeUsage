import Foundation

final class FileWatcher {
    private var source: DispatchSourceFileSystemObject?

    init(url: URL, onChange: @escaping () -> Void) {
        let fd = open(url.path, O_EVTONLY)
        guard fd >= 0 else { return }
        let src = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: .write,
            queue: .main
        )
        src.setEventHandler(handler: onChange)
        src.setCancelHandler { close(fd) }
        src.resume()
        self.source = src
    }

    deinit { source?.cancel() }
}
