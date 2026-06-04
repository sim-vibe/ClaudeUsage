import SwiftUI
import AppKit

struct MenuContentView: View {
    @EnvironmentObject var model: RateLimitsModel
    @State private var isRefreshing = false

    var body: some View {
        if !model.isOnboarded && !model.isDemo {
            OnboardingView()
        } else {
            usageContent
        }
    }

    private var usageContent: some View {
        let rl = model.rateLimits
        let fh = rl?.five_hour
        let sd = rl?.seven_day
        let nowTs = Date().timeIntervalSince1970
        let fhExpired = fh.map { nowTs > $0.resets_at } ?? false

        return VStack(alignment: .leading, spacing: 0) {
            // Top content is inset 14pt; footer rows span full width so their
            // highlight reaches the edges (native-menu look) while their text
            // still starts at the same 14pt as these section titles.
            VStack(alignment: .leading, spacing: 12) {
                if model.isDemo {
                    HStack(spacing: 6) {
                        Label("Demo data — not real usage", systemImage: "wand.and.stars")
                            .font(.caption)
                            .foregroundStyle(.purple)
                        Spacer()
                        Button("Exit") { model.exitDemo() }
                            .buttonStyle(.link)
                            .font(.caption)
                    }
                }
                if model.fileAge > 60 {
                    banner("Data is \(Int(model.fileAge)) min old", icon: "exclamationmark.triangle", color: .orange)
                }
                if fhExpired {
                    banner("5h bucket expired — refreshes after next response", icon: "exclamationmark.triangle", color: .orange)
                }

                usageSection(
                    title: "Current session",
                    pctText: fhExpired ? "0% used" : "\(fh?.pct ?? 0)% used",
                    barPct: fhExpired ? 0 : (fh?.used_percentage ?? 0),
                    subtitle: fhExpired ? "Next response will refresh" : fh.map { formatReset($0.resets_at) }
                )

                Divider()

                usageSection(
                    title: "Current week (all models)",
                    pctText: "\(sd?.pct ?? 0)% used",
                    barPct: sd?.used_percentage ?? 0,
                    subtitle: sd.map { formatReset($0.resets_at) }
                )

                if rl == nil {
                    Text("Appears after a Claude Code session")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)

            Divider()
                .padding(.horizontal, 5)
                .padding(.top, 10)
                .padding(.bottom, 4)

            // Footer actions — full-width rows with native-style hover highlight,
            // text flush-left at the same inset as the section titles above.
            VStack(spacing: 1) {
                Button {
                    model.refresh()
                    // Brief textual feedback so the click registers without an icon.
                    withAnimation(.easeOut(duration: 0.15)) { isRefreshing = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        withAnimation(.easeOut(duration: 0.15)) { isRefreshing = false }
                    }
                } label: {
                    HStack {
                        Text(isRefreshing ? "Refreshing…" : "Refresh")
                        Spacer()
                        if let t = model.lastLoaded {
                            // Clicking refreshes and updates this time in place.
                            Text("Updated \(timeString(t))")
                                .font(.system(size: 10, design: .monospaced))
                                .opacity(0.8)
                        }
                    }
                }
                .buttonStyle(MenuRowButtonStyle())
                .keyboardShortcut("r")

                Divider()
                    .padding(.horizontal, 5)
                    .padding(.vertical, 3)

                Button { showAbout() } label: {
                    HStack { Text("About"); Spacer() }
                }
                .buttonStyle(MenuRowButtonStyle())

                Button { contactSupport() } label: {
                    HStack { Text("Contact Us"); Spacer() }
                }
                .buttonStyle(MenuRowButtonStyle())

                Divider()
                    .padding(.horizontal, 5)
                    .padding(.vertical, 3)

                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    HStack {
                        Text("Quit")
                        Spacer()
                    }
                }
                .buttonStyle(MenuRowButtonStyle())
                .keyboardShortcut("q")
            }
            .padding(.bottom, 6)
        }
        .frame(width: 280, alignment: .leading)
    }

    private func banner(_ text: String, icon: String, color: Color) -> some View {
        Label(text, systemImage: icon)
            .font(.caption)
            .foregroundStyle(color)
    }

    private func usageSection(title: String, pctText: String, barPct: Double, subtitle: String?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(.callout, design: .monospaced).weight(.semibold))
                Spacer()
                Text(pctText)
                    .font(.system(.callout, design: .monospaced))
            }
            UsageBar(pct: barPct)
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func timeString(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "h:mm:ss a"
        return f.string(from: d).lowercased()
    }

    private func showAbout() {
        AboutPanel.show()
    }

    private func contactSupport() {
        if let url = URL(string: "mailto:support@keyz.dev?subject=Token%20Meter%20for%20Claude") {
            NSWorkspace.shared.open(url)
        }
    }

    private func formatReset(_ epoch: TimeInterval) -> String {
        // Use the user's local time zone (no hard-coded region) for an
        // internationalized, English-only display.
        let now = Date()
        let dt = Date(timeIntervalSince1970: epoch)
        let cal = Calendar.current
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US")
        fmt.dateFormat = "h:mma"
        let timeStr = fmt.string(from: dt).lowercased()

        if dt <= now { return "Reset today at \(timeStr)" }
        if cal.isDateInToday(dt) { return "Resets today at \(timeStr)" }
        if cal.isDateInTomorrow(dt) { return "Resets tomorrow at \(timeStr)" }
        fmt.dateFormat = "MMM d"
        return "Resets \(fmt.string(from: dt)) at \(timeStr)"
    }
}

/// Menu-item-like button: full-width row that highlights on hover and
/// darkens while pressed, so clicks are obvious in a `.window` menu bar extra.
struct MenuRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Row(configuration: configuration)
    }

    private struct Row: View {
        let configuration: ButtonStyle.Configuration
        @State private var hovering = false

        private var highlighted: Bool { hovering || configuration.isPressed }

        var body: some View {
            configuration.label
                .foregroundStyle(highlighted ? Color.white : Color.primary)
                // Text starts at 14pt — same inset as the section titles above.
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    // Highlight spans full width minus a 5pt edge inset (native look).
                    RoundedRectangle(cornerRadius: 5)
                        .fill(highlighted ? Color.accentColor.opacity(configuration.isPressed ? 1.0 : 0.9) : .clear)
                        .padding(.horizontal, 5)
                )
                .contentShape(Rectangle())
                .onHover { hovering = $0 }
                .animation(.easeOut(duration: 0.1), value: highlighted)
        }
    }
}

struct UsageBar: View {
    let pct: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.blue.opacity(0.15))
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.blue)
                    .frame(width: geo.size.width * min(pct / 100, 1.0))
            }
        }
        .frame(height: 6)
    }
}
