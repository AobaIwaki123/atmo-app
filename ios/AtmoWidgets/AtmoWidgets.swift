import WidgetKit
import SwiftUI

private let appGroupId = "group.net.aooba.atmo"

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> AtmoEntry {
        AtmoEntry(date: Date(), smallImagePath: nil, mediumImagePath: nil)
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
        let smallPath = userDefaults?.string(forKey: "atmo_small_chart")
        let mediumPath = userDefaults?.string(forKey: "atmo_medium_chart")
        return AtmoEntry(date: Date(), smallImagePath: smallPath, mediumImagePath: mediumPath)
    }
}

struct AtmoEntry: TimelineEntry {
    let date: Date
    let smallImagePath: String?
    let mediumImagePath: String?
}

struct AtmoWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                if let path = entry.smallImagePath, let uiImage = UIImage(contentsOfFile: path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    fallbackView
                }
            case .systemMedium:
                if let path = entry.mediumImagePath, let uiImage = UIImage(contentsOfFile: path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    fallbackView
                }
            default:
                fallbackView
            }
        }
        .containerBackground(Color(red: 15/255, green: 23/255, blue: 42/255), for: .widget)
    }

    var fallbackView: some View {
        VStack(spacing: 6) {
            Image(systemName: "barometer")
                .font(.system(size: 24))
                .foregroundColor(.cyan)
            Text("atmo")
                .font(.headline)
                .foregroundColor(.white)
            Text("アプリを開いて更新")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@main
struct AtmoWidgets: WidgetBundle {
    var body: some Widget {
        AtmoSmallWidget()
        AtmoMediumWidget()
    }
}

struct AtmoSmallWidget: Widget {
    let kind: String = "AtmoSmallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            AtmoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("atmo 気圧推移 (Small)")
        .description("現在地の気圧とスパークライン推移を表示します。")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

struct AtmoMediumWidget: Widget {
    let kind: String = "AtmoMediumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            AtmoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("atmo 気圧推移 (Medium)")
        .description("現在地の気圧とワイド推移グラフを表示します。")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}
