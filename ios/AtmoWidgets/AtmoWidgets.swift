import WidgetKit
import SwiftUI
import UIKit

private let appGroupId = "group.net.iorin.atmoapp.shared"
private let widgetBackground = Color(red: 19 / 255, green: 27 / 255, blue: 46 / 255)
private let graphColor = Color(red: 56 / 255, green: 189 / 255, blue: 248 / 255)

private enum AtmoWidgetTypography {
    static let location = Font.system(size: 12, weight: .medium, design: .rounded)
    static let locationMedium = Font.system(size: 13, weight: .medium, design: .rounded)
    static let timestamp = Font.system(size: 10, weight: .medium, design: .rounded)
    static let timestampMedium = Font.system(size: 11, weight: .medium, design: .rounded)
    static let pressure = Font.system(size: 26, weight: .light, design: .rounded)
    static let pressureMedium = Font.system(size: 25, weight: .light, design: .rounded)
    static let unit = Font.system(size: 9, weight: .medium, design: .rounded)
    static let delta = Font.system(size: 10, weight: .semibold, design: .rounded)
    static let axis = Font.system(size: 8, weight: .medium, design: .rounded)
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> AtmoEntry {
        AtmoEntry(
            date: Date(),
            hasData: true,
            locationName: "東京都",
            currentPressure: "1007.0",
            diff3h: "+1.7",
            hourText: "19:00",
            status: "normal",
            pressures: [1005.8, 1006.2, 1006.8, 1007.0, 1006.7],
            currentIndex: 3,
            smallImagePath: nil,
            mediumImagePath: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (AtmoEntry) -> ()) {
        let entry = createEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = createEntry()
        // 1時間後に再リクエスト (Best Effort)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func createEntry() -> AtmoEntry {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        let pressures = decodeSeries(userDefaults?.string(forKey: "series_json"))
        let currentIndex = Int(userDefaults?.string(forKey: "current_index") ?? "") ?? -1
        let smallImagePath = userDefaults?.string(forKey: "atmo_small_chart")
        let mediumImagePath = userDefaults?.string(forKey: "atmo_medium_chart")
        let hasData = userDefaults?.string(forKey: "current_pressure") != nil
            || smallImagePath != nil
            || mediumImagePath != nil

        return AtmoEntry(
            date: Date(),
            hasData: hasData,
            locationName: userDefaults?.string(forKey: "location_name") ?? "選択地点",
            currentPressure: userDefaults?.string(forKey: "current_pressure") ?? "--.-",
            diff3h: userDefaults?.string(forKey: "diff_3h") ?? "—",
            hourText: userDefaults?.string(forKey: "hour_text") ?? "--:--",
            status: userDefaults?.string(forKey: "status") ?? "normal",
            pressures: pressures,
            currentIndex: currentIndex,
            smallImagePath: smallImagePath,
            mediumImagePath: mediumImagePath
        )
    }

    private func decodeSeries(_ raw: String?) -> [Double] {
        guard
            let raw,
            let data = raw.data(using: .utf8),
            let object = try? JSONSerialization.jsonObject(with: data),
            let values = object as? [Any]
        else {
            return []
        }

        return values.compactMap { ($0 as? NSNumber)?.doubleValue }
    }
}

struct AtmoEntry: TimelineEntry {
    let date: Date
    let hasData: Bool
    let locationName: String
    let currentPressure: String
    let diff3h: String
    let hourText: String
    let status: String
    let pressures: [Double]
    let currentIndex: Int
    let smallImagePath: String?
    let mediumImagePath: String?
}

struct AtmoWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            if !entry.hasData {
                fallbackView
            } else if family == .systemMedium {
                if let image = loadImage(at: entry.mediumImagePath) {
                    imageView(image)
                } else {
                    mediumView
                }
            } else {
                if let image = loadImage(at: entry.smallImagePath) {
                    imageView(image)
                } else {
                    smallView
                }
            }
        }
        .modifier(AtmoWidgetBackgroundModifier())
    }

    private var statusColor: Color {
        switch entry.status {
        case "caution": return Color(red: 248 / 255, green: 113 / 255, blue: 113 / 255)
        case "notice": return Color(red: 251 / 255, green: 191 / 255, blue: 36 / 255)
        default: return Color(red: 52 / 255, green: 211 / 255, blue: 153 / 255)
        }
    }

    private var diffText: String {
        entry.diff3h == "—" ? entry.diff3h : "3h \(entry.diff3h)"
    }

    private func loadImage(at path: String?) -> UIImage? {
        guard let path, !path.isEmpty else { return nil }

        let filePath: String
        if path.hasPrefix("file://"), let url = URL(string: path) {
            filePath = url.path
        } else {
            filePath = path
        }
        return UIImage(contentsOfFile: filePath)
    }

    private func imageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .accessibilityHidden(true)
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "mappin.circle")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.65))
                Text(entry.locationName)
                    .font(AtmoWidgetTypography.location)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Spacer(minLength: 2)
                Text(entry.hourText)
                    .font(AtmoWidgetTypography.timestamp)
                    .foregroundColor(.white.opacity(0.55))
            }

            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(entry.currentPressure)
                    .font(AtmoWidgetTypography.pressure)
                    .foregroundColor(.white)
                    .monospacedDigit()
                    .minimumScaleFactor(0.65)
                Text("hPa")
                    .font(AtmoWidgetTypography.unit)
                    .foregroundColor(.white.opacity(0.45))
                Spacer(minLength: 2)
                Text(entry.diff3h)
                    .font(AtmoWidgetTypography.delta)
                    .foregroundColor(statusColor)
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
            }
            .padding(.top, 5)

            AtmoSparkline(
                pressures: entry.pressures,
                currentIndex: entry.currentIndex,
                lineColor: graphColor
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 5)
        }
        .padding(12)
    }

    private var mediumView: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.65))
                    Text(entry.locationName)
                        .font(AtmoWidgetTypography.locationMedium)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Text(entry.hourText)
                    .font(AtmoWidgetTypography.timestampMedium)
                    .foregroundColor(.white.opacity(0.55))
                    .padding(.top, 2)
                Spacer(minLength: 4)
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text(entry.currentPressure)
                        .font(AtmoWidgetTypography.pressureMedium)
                        .foregroundColor(.white)
                        .monospacedDigit()
                        .minimumScaleFactor(0.6)
                    Text("hPa")
                        .font(AtmoWidgetTypography.unit)
                        .foregroundColor(.white.opacity(0.45))
                }
                Text(diffText)
                    .font(AtmoWidgetTypography.delta)
                    .foregroundColor(statusColor)
                    .monospacedDigit()
                    .padding(.top, 2)
            }
            .frame(width: 112, alignment: .leading)

            VStack(spacing: 3) {
                AtmoSparkline(
                    pressures: entry.pressures,
                    currentIndex: entry.currentIndex,
                    lineColor: graphColor
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                HStack {
                    Text("-12h")
                    Spacer()
                    Text("現在")
                    Spacer()
                    Text("+12h")
                }
                .font(AtmoWidgetTypography.axis)
                .foregroundColor(.white.opacity(0.35))
            }
        }
        .padding(14)
    }

    var fallbackView: some View {
        VStack(spacing: 6) {
            Image(systemName: "barometer")
                .font(.system(size: 24))
                .foregroundColor(.cyan)
            Text("ソラケア")
                .font(.headline)
                .foregroundColor(.white)
            Text("アプリを開いて更新")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct AtmoSparkline: View {
    let pressures: [Double]
    let currentIndex: Int
    let lineColor: Color

    var body: some View {
        Canvas { context, size in
            guard pressures.count > 1 else { return }

            let minimum = pressures.min() ?? 0
            let maximum = pressures.max() ?? minimum
            let valueRange = max(maximum - minimum, 2.0)
            let horizontalStep = size.width / CGFloat(pressures.count - 1)
            let points = pressures.enumerated().map { index, value in
                let normalized = (value - minimum) / valueRange
                return CGPoint(
                    x: CGFloat(index) * horizontalStep,
                    y: size.height * 0.84 - CGFloat(normalized) * size.height * 0.66
                )
            }

            var path = Path()
            path.move(to: points[0])
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            context.stroke(
                path,
                with: .color(lineColor),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
            )

            if currentIndex >= 0 && currentIndex < points.count {
                let point = points[currentIndex]
                var guide = Path()
                guide.move(to: CGPoint(x: point.x, y: 0))
                guide.addLine(to: CGPoint(x: point.x, y: size.height))
                context.stroke(
                    guide,
                    with: .color(.white.opacity(0.22)),
                    style: StrokeStyle(lineWidth: 1, dash: [2, 2])
                )
                context.fill(
                    Path(ellipseIn: CGRect(x: point.x - 4, y: point.y - 4, width: 8, height: 8)),
                    with: .color(.white)
                )
                context.fill(
                    Path(ellipseIn: CGRect(x: point.x - 2, y: point.y - 2, width: 4, height: 4)),
                    with: .color(lineColor)
                )
            }
        }
    }
}

private struct AtmoWidgetBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.containerBackground(
                widgetBackground,
                for: .widget
            )
        } else {
            content.background(widgetBackground)
        }
    }
}

@main
struct AtmoWidgets: WidgetBundle {
    var body: some Widget {
        AtmoSmallWidget()
    }
}

struct AtmoSmallWidget: Widget {
    let kind: String = "AtmoSmallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            AtmoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("ソラケア 気圧推移")
        .description("選択地点の気圧と推移グラフを表示します。")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}
