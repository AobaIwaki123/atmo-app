import WidgetKit
import SwiftUI

@main
struct AtmoWidgets: WidgetBundle {
    var body: some Widget {
        AtmoSmallWidget()
    }
}

struct AtmoSmallWidget: Widget {
    let kind: String = "AtmoSmallWidget"

    private var supportedFamilies: [WidgetFamily] {
        if #available(iOS 16.0, *) {
            return [
                .systemSmall,
                .systemMedium,
                .accessoryRectangular,
                .accessoryCircular,
                .accessoryInline,
            ]
        } else {
            return [
                .systemSmall,
                .systemMedium,
            ]
        }
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AtmoWidgetProvider()) { entry in
            AtmoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("ソラケア 気圧推移")
        .description("選択地点の気圧と推移グラフを表示します。")
        .supportedFamilies(supportedFamilies)
        .contentMarginsDisabled()
    }
}
