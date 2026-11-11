import SwiftUI

/// SwiftUIウィジェットの見た目を定義するトークン。
///
/// Flutter側の `widget_design_tokens.dart` と厳密に対応し、レイアウト側に
/// 色・文字サイズ・余白のリテラルを増やさない。
enum AtmoWidgetDesign {
    static let surface = Color(red: 16 / 255, green: 24 / 255, blue: 39 / 255)
    static let primaryText = Color(red: 248 / 255, green: 250 / 255, blue: 252 / 255)
    static let secondaryText = Color(red: 248 / 255, green: 250 / 255, blue: 252 / 255).opacity(0.72)
    static let tertiaryText = Color(red: 248 / 255, green: 250 / 255, blue: 252 / 255).opacity(0.47)
    static let mutedText = Color(red: 248 / 255, green: 250 / 255, blue: 252 / 255).opacity(0.36)
    static let graph = Color(red: 92 / 255, green: 200 / 255, blue: 255 / 255)
    static let normal = Color(red: 98 / 255, green: 214 / 255, blue: 176 / 255)
    static let notice = Color(red: 245 / 255, green: 196 / 255, blue: 81 / 255)
    static let caution = Color(red: 255 / 255, green: 122 / 255, blue: 120 / 255)
    static let guide = Color.white.opacity(0.25)
    static let border = Color.white.opacity(0.08)

    enum Spacing {
        static let iconToText: CGFloat = 4
        static let smallTop: CGFloat = 12
        static let smallHorizontal: CGFloat = 14
        static let mediumTop: CGFloat = 14
        static let mediumHorizontal: CGFloat = 18
        static let section: CGFloat = 6
        static let chart: CGFloat = 5
        static let baseline: CGFloat = 3
        static let smallSpacer: CGFloat = 2
        static let mediumStack: CGFloat = 0
        static let accessoryStack: CGFloat = 2
        static let accessoryRectangularGap: CGFloat = 8
    }

    enum Metrics {
        static let cardRadius: CGFloat = 24
        static let smallPadding: CGFloat = 12
        static let mediumPadding: CGFloat = 14
        static let mediumInfoWidth: CGFloat = 110
        static let mediumColumnGap: CGFloat = 12
        static let mediumChartStackGap: CGFloat = 4
        static let mediumMetadataTop: CGFloat = 2
        static let statusDot: CGFloat = 6
        static let smallMinimumScale: CGFloat = 0.75
        static let mediumMinimumScale: CGFloat = 0.7
        static let pressureMinimumScale: CGFloat = 0.65
        static let pressureMediumMinimumScale: CGFloat = 0.6
        static let fallbackIconSize: CGFloat = 24
        static let pressureGaugeMin: Double = 970.0
        static let pressureGaugeMax: Double = 1040.0
    }

    enum Chart {
        static let plotBottom: CGFloat = 0.84
        static let plotHeight: CGFloat = 0.66
        static let strokeWidth: CGFloat = 2.2
        static let guideStrokeWidth: CGFloat = 1
        static let guideTop: CGFloat = 4
        static let outerDotRadius: CGFloat = 4
        static let innerDotRadius: CGFloat = 2.5
        static let fillOpacity: Double = 0.22
        static let guideDash: [CGFloat] = [2, 2]
    }

    enum Typography {
        static let icon = Font.system(size: 11, weight: .regular, design: .default)
        static let iconMedium = Font.system(size: 12, weight: .regular, design: .default)
        static let location = Font.system(size: 12, weight: .semibold, design: .default)
        static let locationMedium = Font.system(size: 13, weight: .semibold, design: .default)
        static let timestamp = Font.system(size: 11, weight: .regular, design: .default)
        static let pressure = Font.system(size: 26, weight: .light, design: .default)
        static let pressureMedium = Font.system(size: 27, weight: .light, design: .default)
        static let unit = Font.system(size: 10, weight: .regular, design: .default)
        static let delta = Font.system(size: 11, weight: .semibold, design: .default)
        static let axis = Font.system(size: 10, weight: .regular, design: .default)
        static let accessoryTitle = Font.system(size: 12, weight: .semibold, design: .default)
        static let accessoryPressure = Font.system(size: 20, weight: .semibold, design: .default)
        static let accessoryUnit = Font.system(size: 9, weight: .regular, design: .default)
        static let accessoryDelta = Font.system(size: 11, weight: .medium, design: .default)
        static let accessoryCircularPressure = Font.system(size: 15, weight: .bold, design: .default)
        static let accessoryCircularDelta = Font.system(size: 9, weight: .semibold, design: .default)
        static let accessoryInline = Font.system(size: 13, weight: .regular, design: .default)
    }

    static func statusColor(for status: String) -> Color {
        switch status {
        case "caution": return caution
        case "notice": return notice
        default: return normal
        }
    }

    static func trendSymbol(for diff: String) -> String {
        if diff.hasPrefix("+") {
            return "arrow.up.right"
        } else if diff.hasPrefix("-") {
            return "arrow.down.right"
        } else {
            return "arrow.forward"
        }
    }
}
