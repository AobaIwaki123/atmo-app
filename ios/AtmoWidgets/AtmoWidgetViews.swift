import SwiftUI
import UIKit
import WidgetKit

struct AtmoWidgetEntryView: View {
    var entry: AtmoEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            if !entry.hasData {
                fallbackView
            } else if family == .systemMedium {
                mediumView
            } else if #available(iOS 16.0, *), family == .accessoryRectangular {
                accessoryRectangularView
            } else if #available(iOS 16.0, *), family == .accessoryCircular {
                accessoryCircularView
            } else if #available(iOS 16.0, *), family == .accessoryInline {
                accessoryInlineView
            } else {
                smallView
            }
        }
        .modifier(AtmoWidgetBackgroundModifier(family: family))
    }

    private var statusColor: Color {
        AtmoWidgetDesign.statusColor(for: entry.status)
    }

    private var diffText: String {
        entry.diff3h == "—" ? entry.diff3h : "3h \(entry.diff3h)"
    }

    private var accessibilityText: String {
        "\(entry.locationName)、現在の気圧 \(entry.currentPressure) hPa、3時間差 \(entry.diff3h)"
    }

    private func imageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .accessibilityLabel(accessibilityText)
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: AtmoWidgetDesign.Spacing.mediumStack) {
            HStack(spacing: AtmoWidgetDesign.Spacing.iconToText) {
                Image(systemName: "mappin.circle")
                    .font(AtmoWidgetDesign.Typography.icon)
                    .foregroundColor(AtmoWidgetDesign.secondaryText)
                Text(entry.locationName)
                    .font(AtmoWidgetDesign.Typography.location)
                    .foregroundColor(AtmoWidgetDesign.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(AtmoWidgetDesign.Metrics.smallMinimumScale)
                Spacer(minLength: AtmoWidgetDesign.Spacing.smallSpacer)
                Text(entry.hourText)
                    .font(AtmoWidgetDesign.Typography.timestamp)
                    .foregroundColor(AtmoWidgetDesign.secondaryText)
                Circle()
                    .fill(statusColor)
                    .frame(
                        width: AtmoWidgetDesign.Metrics.statusDot,
                        height: AtmoWidgetDesign.Metrics.statusDot
                    )
            }

            HStack(alignment: .lastTextBaseline, spacing: AtmoWidgetDesign.Spacing.baseline) {
                Text(entry.currentPressure)
                    .font(AtmoWidgetDesign.Typography.pressure)
                    .foregroundColor(AtmoWidgetDesign.primaryText)
                    .monospacedDigit()
                    .minimumScaleFactor(AtmoWidgetDesign.Metrics.pressureMinimumScale)
                Text("hPa")
                    .font(AtmoWidgetDesign.Typography.unit)
                    .foregroundColor(AtmoWidgetDesign.tertiaryText)
                Spacer(minLength: AtmoWidgetDesign.Spacing.smallSpacer)
                Text(entry.diff3h)
                    .font(AtmoWidgetDesign.Typography.delta)
                    .foregroundColor(statusColor)
                    .monospacedDigit()
                    .minimumScaleFactor(AtmoWidgetDesign.Metrics.mediumMinimumScale)
            }
            .padding(.top, AtmoWidgetDesign.Spacing.section)

            AtmoSparkline(
                pressures: entry.pressures,
                currentIndex: entry.currentIndex,
                lineColor: AtmoWidgetDesign.graph
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, AtmoWidgetDesign.Spacing.chart)
        }
        .padding(.horizontal, AtmoWidgetDesign.Spacing.smallHorizontal)
        .padding(.vertical, AtmoWidgetDesign.Spacing.smallTop)
    }

    private var mediumView: some View {
        HStack(spacing: AtmoWidgetDesign.Metrics.mediumColumnGap) {
            VStack(alignment: .leading, spacing: AtmoWidgetDesign.Spacing.mediumStack) {
                HStack(spacing: AtmoWidgetDesign.Spacing.iconToText) {
                    Image(systemName: "mappin.circle")
                        .font(AtmoWidgetDesign.Typography.iconMedium)
                        .foregroundColor(AtmoWidgetDesign.secondaryText)
                    Text(entry.locationName)
                        .font(AtmoWidgetDesign.Typography.locationMedium)
                        .foregroundColor(AtmoWidgetDesign.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(AtmoWidgetDesign.Metrics.mediumMinimumScale)
                }
                Text(entry.hourText)
                    .font(AtmoWidgetDesign.Typography.timestamp)
                    .foregroundColor(AtmoWidgetDesign.secondaryText)
                    .padding(.top, AtmoWidgetDesign.Metrics.mediumMetadataTop)
                Spacer(minLength: AtmoWidgetDesign.Metrics.mediumMetadataTop * 2)
                HStack(alignment: .lastTextBaseline, spacing: AtmoWidgetDesign.Spacing.baseline) {
                    Text(entry.currentPressure)
                        .font(AtmoWidgetDesign.Typography.pressureMedium)
                        .foregroundColor(AtmoWidgetDesign.primaryText)
                        .monospacedDigit()
                        .minimumScaleFactor(AtmoWidgetDesign.Metrics.pressureMediumMinimumScale)
                    Text("hPa")
                        .font(AtmoWidgetDesign.Typography.unit)
                        .foregroundColor(AtmoWidgetDesign.tertiaryText)
                }
                Text(diffText)
                    .font(AtmoWidgetDesign.Typography.delta)
                    .foregroundColor(statusColor)
                    .monospacedDigit()
                    .padding(.top, AtmoWidgetDesign.Metrics.mediumMetadataTop)
            }
            .frame(width: AtmoWidgetDesign.Metrics.mediumInfoWidth, alignment: .leading)

            VStack(spacing: AtmoWidgetDesign.Metrics.mediumChartStackGap) {
                AtmoSparkline(
                    pressures: entry.pressures,
                    currentIndex: entry.currentIndex,
                    lineColor: AtmoWidgetDesign.graph
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                HStack {
                    Text("-12h")
                    Spacer()
                    Text("現在")
                    Spacer()
                    Text("+12h")
                }
                .font(AtmoWidgetDesign.Typography.axis)
                .foregroundColor(AtmoWidgetDesign.mutedText)
            }
        }
        .padding(.horizontal, AtmoWidgetDesign.Spacing.mediumHorizontal)
        .padding(.vertical, AtmoWidgetDesign.Spacing.mediumTop)
    }

    @available(iOS 16.0, *)
    private var accessoryRectangularView: some View {
        VStack(alignment: .leading, spacing: AtmoWidgetDesign.Spacing.accessoryStack) {
            HStack(spacing: AtmoWidgetDesign.Spacing.iconToText) {
                Image(systemName: "mappin")
                    .font(AtmoWidgetDesign.Typography.accessoryTitle)
                Text(entry.locationName)
                    .font(AtmoWidgetDesign.Typography.accessoryTitle)
                    .lineLimit(1)
                Spacer(minLength: AtmoWidgetDesign.Spacing.smallSpacer)
                HStack(spacing: 2) {
                    Image(systemName: AtmoWidgetDesign.trendSymbol(for: entry.diff3h))
                    Text(entry.diff3h)
                }
                .font(AtmoWidgetDesign.Typography.accessoryDelta)
            }

            HStack(alignment: .bottom, spacing: AtmoWidgetDesign.Spacing.accessoryRectangularGap) {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(entry.currentPressure)
                        .font(AtmoWidgetDesign.Typography.accessoryPressure)
                        .monospacedDigit()
                    Text("hPa")
                        .font(AtmoWidgetDesign.Typography.accessoryUnit)
                        .foregroundColor(.secondary)
                }
                .layoutPriority(1)

                AtmoSparkline(
                    pressures: entry.pressures,
                    currentIndex: entry.currentIndex,
                    lineColor: .primary,
                    dotBackgroundColor: .clear
                )
                .widgetAccentable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    @available(iOS 16.0, *)
    private var accessoryCircularView: some View {
        let pressureValue = Double(entry.currentPressure) ?? 1013.0
        return Gauge(
            value: pressureValue,
            in: AtmoWidgetDesign.Metrics.pressureGaugeMin...AtmoWidgetDesign.Metrics.pressureGaugeMax
        ) {
            Text("気圧")
        } currentValueLabel: {
            VStack(spacing: 0) {
                Text(entry.currentPressure)
                    .font(AtmoWidgetDesign.Typography.accessoryCircularPressure)
                    .monospacedDigit()
                    .minimumScaleFactor(0.8)
                HStack(spacing: 1) {
                    Image(systemName: AtmoWidgetDesign.trendSymbol(for: entry.diff3h))
                    Text(entry.diff3h)
                }
                .font(AtmoWidgetDesign.Typography.accessoryCircularDelta)
                .lineLimit(1)
            }
        }
        .gaugeStyle(.accessoryCircular)
    }

    @available(iOS 16.0, *)
    private var accessoryInlineView: some View {
        HStack(spacing: 4) {
            Image(systemName: "barometer")
            Text("\(entry.locationName) \(entry.currentPressure)hPa")
            Text("(\(entry.diff3h))")
        }
    }

    @ViewBuilder
    private var fallbackView: some View {
        if #available(iOS 16.0, *) {
            switch family {
            case .accessoryInline:
                Text("ソラケア: データなし")
            case .accessoryCircular:
                Image(systemName: "barometer")
            case .accessoryRectangular:
                VStack(alignment: .leading, spacing: 2) {
                    Text("ソラケア")
                        .font(AtmoWidgetDesign.Typography.accessoryTitle)
                    Text("アプリを開いて更新")
                        .font(AtmoWidgetDesign.Typography.accessoryUnit)
                        .foregroundColor(.secondary)
                }
            default:
                defaultFallbackView
            }
        } else {
            defaultFallbackView
        }
    }

    private var defaultFallbackView: some View {
        VStack(spacing: AtmoWidgetDesign.Spacing.section) {
            Image(systemName: "barometer")
                .font(.system(
                    size: AtmoWidgetDesign.Metrics.fallbackIconSize,
                    weight: .regular,
                    design: .default
                ))
                .foregroundColor(AtmoWidgetDesign.graph)
            Text("ソラケア")
                .font(.headline)
                .foregroundColor(AtmoWidgetDesign.primaryText)
            Text("アプリを開いて更新")
                .font(.caption)
                .foregroundColor(AtmoWidgetDesign.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct AtmoWidgetBackgroundModifier: ViewModifier {
    let family: WidgetFamily

    func body(content: Content) -> some View {
        if isAccessoryFamily {
            if #available(iOS 17.0, *) {
                content.containerBackground(Color.clear, for: .widget)
            } else {
                content.background(Color.clear)
            }
        } else {
            if #available(iOS 17.0, *) {
                content.containerBackground(AtmoWidgetDesign.surface, for: .widget)
            } else {
                content.background(AtmoWidgetDesign.surface)
            }
        }
    }

    private var isAccessoryFamily: Bool {
        if #available(iOS 16.0, *) {
            switch family {
            case .accessoryRectangular, .accessoryCircular, .accessoryInline:
                return true
            default:
                return false
            }
        } else {
            return false
        }
    }
}
