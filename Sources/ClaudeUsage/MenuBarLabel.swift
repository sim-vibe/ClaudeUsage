import SwiftUI

struct MenuBarLabel: View {
    @EnvironmentObject var model: RateLimitsModel

    private var sessionPct: Int { model.rateLimits?.five_hour?.used_percentage ?? 0 }
    private var weekPct: Int { model.rateLimits?.seven_day?.used_percentage ?? 0 }

    var body: some View {
        HStack(spacing: 4) {
            RobotIcon(frameIndex: model.frameIndex)
            if model.isOnboarded && model.rateLimits != nil {
                Text("\(sessionPct)% · \(weekPct)%w")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
            }
        }
    }
}

struct RobotIcon: View {
    let frameIndex: Int

    private let frames: [String] = [
        "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAPElEQVR4nGNgoAd4VmHzH4RJlaOtgWfC9f9TgulnoAwXMxyja8InN4QNpFmkILsGGx54F1Js4CgYBQMIAIMPRD5frZskAAAAAElFTkSuQmCC",
        "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAPklEQVR4nGNgwAGeVdj8B2FS5XACig08E67/nxJMPwNluJjhGF0TPrkhbCDNIgXZNdjwwLuQYgNHwSgYTgAAyHdEPnnXhWwAAAAASUVORK5CYII=",
        "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAOElEQVR4nGNgoAd4VmHzH4RJlaOtgWfC9f9TgulnoAwXMxyPEANpFinILsWGB96FFBs4CkbBAAIAwMNOr1vWRjoAAAAASUVORK5CYII=",
        "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAQElEQVR4nGNgQAPPKmz+gzC6OCE5nIBqBp4J1/9PCaafgTJczHCMrgmf3BA2kGaRguwabHjgXUixgaNgFAwnAABuxkQ+edIaowAAAABJRU5ErkJggg==",
    ]

    var body: some View {
        if let data = Data(base64Encoded: frames[frameIndex % 4]),
           let img = NSImage(data: data) {
            Image(nsImage: img)
                .interpolation(.none)
                .resizable()
                .frame(width: 16, height: 16)
        }
    }
}
