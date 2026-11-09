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
            } else {
                smallView
            }
        }
        .modifier(AtmoWidgetBackgroundModifier())
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

    private var fallbackView: some View {
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
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.containerBackground(AtmoWidgetDesign.surface, for: .widget)
        } else {
            content.background(AtmoWidgetDesign.surface)
        }
    }
}
