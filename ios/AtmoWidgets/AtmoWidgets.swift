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

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AtmoWidgetProvider()) { entry in
            AtmoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("ソラケア 気圧推移")
        .description("選択地点の気圧と推移グラフを表示します。")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}
