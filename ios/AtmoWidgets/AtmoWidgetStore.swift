import Foundation
import UIKit

enum AtmoWidgetStore {
    static let appGroupId = "group.net.iorin.atmoapp.shared"

    static func loadEntry() -> AtmoEntry {
        let userDefaults = UserDefaults(suiteName: appGroupId)
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
            pressures: decodeSeries(userDefaults?.string(forKey: "series_json")),
            currentIndex: Int(userDefaults?.string(forKey: "current_index") ?? "") ?? -1,
            smallImagePath: smallImagePath,
            mediumImagePath: mediumImagePath
        )
    }

    static func loadImage(at path: String?) -> UIImage? {
        guard let path, !path.isEmpty else { return nil }

        let filePath: String
        if path.hasPrefix("file://"), let url = URL(string: path) {
            filePath = url.path
        } else {
            filePath = path
        }
        return UIImage(contentsOfFile: filePath)
    }

    private static func decodeSeries(_ raw: String?) -> [Double] {
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
