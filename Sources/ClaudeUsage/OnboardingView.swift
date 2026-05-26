import SwiftUI
import AppKit

struct OnboardingView: View {
    @EnvironmentObject var model: RateLimitsModel
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cpu")
                .font(.system(size: 40))
                .foregroundStyle(.blue)

            Text("Claude Usage")
                .font(.title2.bold())

            Text("Claude Code의 토큰 사용량을 메뉴바에서 확인하세요.\n시작하려면 Claude Code 설정 폴더 접근을 허용해주세요.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .font(.callout)

            if let error = errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            Button("~/.claude 폴더 선택") {
                selectFolder()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Text("선택 → 앱이 설정 파일을 자동으로 구성합니다.")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(28)
        .frame(width: 340)
    }

    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Claude Code 설정 폴더(~/.claude)를 선택해주세요."
        panel.prompt = "허용"
        panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(".claude")

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            try BookmarkManager.shared.saveBookmark(for: url)
            try HookInstaller.install(in: url)
            model.onboardingCompleted()
        } catch {
            errorMessage = "설정 실패: \(error.localizedDescription)"
        }
    }
}
