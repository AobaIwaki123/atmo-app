import WidgetKit

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
