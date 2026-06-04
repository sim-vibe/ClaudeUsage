import SwiftUI

struct MenuBarLabel: View {
    @EnvironmentObject var model: RateLimitsModel

    private var sessionPct: Int { model.rateLimits?.five_hour?.pct ?? 0 }
    private var weekPct: Int { model.rateLimits?.seven_day?.pct ?? 0 }

    var body: some View {
        HStack(spacing: 4) {
            RobotIcon(frameIndex: model.frameIndex)
            if (model.isOnboarded || model.isDemo) && model.rateLimits != nil {
                Text("\(sessionPct)% · \(weekPct)%w")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
            } else if !model.isOnboarded && !model.isDemo {
                // Before setup: a short call to action.
                Text("Start")
                    .font(.system(size: 11, weight: .medium))
            }
        }
    }
}

struct RobotIcon: View {
    let frameIndex: Int
    var size: CGFloat = 16

    // Matches the original SwiftBar widget's custom robot frames
    // (~/.claude/widgets/robot_frame_{0-3}.png), embedded as base64.
    private let frames: [String] = [
        "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAl0lEQVR4nGNgGAWUAkZ0gScFHv+J1bzl+CWGjJPPUMxgwTDw0QsK3MfAwITsshNBBmDXdT36xRCy7xZWDehyJ4IM/iP7igmby07deYDTBdjkniDpxfAyCKxxUsNpID45rJEC8zYx4MLTVxiRAvcytQALNlupaqCBtBiYtlh3ASM4kIMElzwjMmeGuRRK+KGHDyH5UTBSAAA0sUB7VXuzRwAAAABJRU5ErkJggg==",
        "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAlUlEQVR4nGNgGOyAEV3gSYHHf2I1bzl+iSHj5DMUM1gwDHz0ggL3MTAwIbvsRJAB2HVdj34xhOy7hVUDutyJIIP/yL5iwuayU3ce4HQBNrknSHoxvAwCa5zUcBqITw5rpMC8TQy48PQVRqTAvUwtwILNVpqAE0EG8FjHxscFmKjtECZqG8iITXCGuRRer6HH7CgYaQAAEHg/h6QoM6QAAAAASUVORK5CYII=",
        "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAg0lEQVR4nGNkQANPCjz+MxAJthy/xJBx8hkjshgLhoGPXjBQApiQXXYiyADsuq5HvxhC9t3CqgFd7kSQwX9kXzFhc9mpOw9wugCb3BMkvRheBoE1Tmo4DcQnBwIoAQoCMG8TAy48fYURKXAvUwuwYLOVJuBEkAE81rHxR8EoGAWDCgAAbdQ7gmTk2zAAAAAASUVORK5CYII=",
        "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAlElEQVR4nGNgGOyAEV3gSYHHf2I1bzl+iSHj5DMUM1gwDHz0ggL3MTAwIbvsRJAB2HVdj34xhOy7hVUDutyJIIP/yL5iwuayU3ce4HQBNrknSHoxvAwCa5zUcBqITw5rpMC8TQy48PQVRqTAvUwtwILNVqqDE0EG8BgnRpymXmaitoGM6AIzzKVQvASLRVzio2AkAgBS8EOHSHzYsAAAAABJRU5ErkJggg==",
    ]

    var body: some View {
        if let data = Data(base64Encoded: frames[frameIndex % 4]),
           let img = NSImage(data: data) {
            Image(nsImage: img)
                .interpolation(.none)
                .resizable()
                .frame(width: size, height: size)
        }
    }
}
