# Token Meter for Claude — App Store 업로드 인수인계

## 현재 상황

App Store Connect 메타데이터 설정 **완료**. 남은 작업은 **Xcode에서 빌드 → App Store Connect 업로드** 한 단계뿐.

## 앱 정보

| 항목 | 값 |
|------|-----|
| 앱 이름 | Token Meter for Claude |
| 번들 ID | `com.simvibe.ClaudeUsage` |
| Apple ID (앱) | `6773230249` |
| GitHub | https://github.com/sim-vibe/ClaudeUsage |
| 개발자 계정 | Gwangseop Shim |
| 지원 이메일 | ccusage@icloud.com |

## App Store Connect 완료된 항목

- ✅ 앱 이름 / 부제 / 설명 / 키워드
- ✅ 스크린샷 2장
- ✅ 지원 URL / 마케팅 URL / 개인정보 처리방침 URL
- ✅ 가격: 무료 (175개국)
- ✅ 개인정보: 데이터 수집 없음 (게시 완료)
- ✅ 연령 등급: 4+
- ✅ 카테고리: 개발자 도구

## 지금 해야 할 작업

### 1단계 — 프로젝트 clone

```bash
git clone https://github.com/sim-vibe/ClaudeUsage.git
cd ClaudeUsage
open Package.swift
```

### 2단계 — Xcode 설정

Xcode가 열리면:

1. 좌측 네비게이터에서 **ClaudeUsage** 패키지 클릭
2. **TARGETS → ClaudeUsage** 선택
3. **Signing & Capabilities** 탭:
   - ✅ Automatically manage signing
   - Team: **Gwangseop Shim** (개인 계정)
   - Bundle Identifier: `com.simvibe.ClaudeUsage`
4. **Info.plist** 또는 빌드 설정에 아래 키 추가:
   - `ITSAppUsesNonExemptEncryption` = `NO`

### 3단계 — Archive

- **Product → Archive** (Release 빌드 자동)
- Organizer 창이 열리면 방금 만든 archive 선택

### 4단계 — App Store Connect 업로드

1. **Distribute App** 클릭
2. **App Store Connect** 선택 → Next
3. **Upload** 선택 → Next
4. 자동으로 서명 및 업로드 진행

### 5단계 — App Store Connect에서 빌드 연결

업로드 완료 후 (보통 5~10분 소요):

1. https://appstoreconnect.apple.com/apps/6773230249/distribution/macos/version/inflight 접속
2. **빌드** 섹션에서 방금 업로드한 빌드 선택
3. **심사를 위해 제출** 클릭

## 주의사항

- SPM(Swift Package Manager) 기반 프로젝트 — `.xcodeproj` 파일 없음, `Package.swift`로 Xcode에서 직접 열면 됨
- macOS 13+ 전용 앱
- Entitlements: App Sandbox + user-selected files (read-write) + security-scoped bookmarks

## 소스 구조

```
Sources/ClaudeUsage/
├── ClaudeUsageApp.swift      # @main, MenuBarExtra
├── RateLimitsModel.swift     # 데이터 모델 + 파일 와처
├── BookmarkManager.swift     # Security-scoped bookmark
├── HookInstaller.swift       # ~/.claude/settings.json 훅 설치
├── FileWatcher.swift         # DispatchSource 파일 감시
├── MenuBarLabel.swift        # 픽셀아트 로봇 애니메이션
├── MenuContentView.swift     # 드롭다운 UI
└── OnboardingView.swift      # 최초 실행 폴더 선택
```
