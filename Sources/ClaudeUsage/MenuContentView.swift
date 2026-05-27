import SwiftUI

struct MenuContentView: View {
    @EnvironmentObject var model: RateLimitsModel

    var body: some View {
        if !model.isOnboarded {
            OnboardingView()
        } else {
            usageContent
        }
    }

    @ViewBuilder
    private var usageContent: some View {
        let rl = model.rateLimits

        if rl == nil {
            waitingForData
        } else {
            usageBody(rl: rl)
        }
    }

    @ViewBuilder
    private var waitingForData: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 30))
                .foregroundStyle(.green)
            Text("Setup complete")
                .font(.headline)
            Text("Make a request in Claude Code to see your token usage here.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Divider().padding(.vertical, 4)

            Button("↺ Refresh") {
                model.refresh()
            }
            .keyboardShortcut("r")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(width: 300)
    }

    @ViewBuilder
    private func usageBody(rl: RateLimits?) -> some View {
        let fh = rl?.five_hour
        let sd = rl?.seven_day
        let nowTs = Date().timeIntervalSince1970
        let fhExpired = fh.map { nowTs > $0.resets_at } ?? false

        if model.fileAge > 60 {
            Label("Data is \(Int(model.fileAge))min old", systemImage: "exclamationmark.triangle")
                .foregroundStyle(.orange)
        }

        if fhExpired {
            Label("5h window expired — refreshes after next response", systemImage: "exclamationmark.triangle")
                .foregroundStyle(.orange)
            Divider()
        }

        // Current session
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Current session")
                    .font(.system(.body, design: .monospaced).bold())
                Spacer()
                Text(fhExpired ? "0% used" : "\(fh?.used_percentage ?? 0)% used")
                    .font(.system(.body, design: .monospaced))
            }
            UsageBar(pct: fhExpired ? 0 : Double(fh?.used_percentage ?? 0))
            if let ra = fh?.resets_at {
                Text(formatReset(ra))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
            } else if fhExpired {
                Text("Next response will refresh")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)

        Divider()

        // Current week
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Current week (all models)")
                    .font(.system(.body, design: .monospaced).bold())
                Spacer()
                Text("\(sd?.used_percentage ?? 0)% used")
                    .font(.system(.body, design: .monospaced))
            }
            UsageBar(pct: Double(sd?.used_percentage ?? 0))
            if let ra = sd?.resets_at {
                Text(formatReset(ra))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)

        Divider()

        Button("↺ Refresh") {
            model.refresh()
        }
        .keyboardShortcut("r")
    }

    private func formatReset(_ epoch: TimeInterval) -> String {
        let tz = TimeZone.current
        let now = Date()
        let dt = Date(timeIntervalSince1970: epoch)
        var cal = Calendar.current
        cal.timeZone = tz
        let fmt = DateFormatter()
        fmt.timeZone = tz
        fmt.dateFormat = "h:mma"
        let timeStr = fmt.string(from: dt).lowercased()

        if dt <= now { return "Reset today at \(timeStr)" }
        if cal.isDateInToday(dt) { return "Resets today at \(timeStr)" }
        if cal.isDateInTomorrow(dt) { return "Resets tomorrow at \(timeStr)" }
        fmt.dateFormat = "MMM d"
        return "Resets \(fmt.string(from: dt)) at \(timeStr)"
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
