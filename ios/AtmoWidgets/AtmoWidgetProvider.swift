import WidgetKit

struct AtmoWidgetProvider: TimelineProvider {
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

    func getSnapshot(in context: Context, completion: @escaping (AtmoEntry) -> Void) {
        completion(AtmoWidgetStore.loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AtmoEntry>) -> Void) {
        Task {
            let (entries, nextReload) = await AtmoWidgetStore.fetchTimelineEntries()
            completion(Timeline(entries: entries, policy: .after(nextReload)))
        }
    }
}
