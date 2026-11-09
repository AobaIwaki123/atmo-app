import Foundation
import UIKit

struct AtmoPointPayload: Codable {
    let time: String
    let pressure: Double
    let isCurrent: Bool?

    enum CodingKeys: String, CodingKey {
        case time
        case pressure
        case isCurrent = "is_current"
    }
}

struct AtmoReportPayload: Codable {
    let updatedAt: String?
    let currentPressure: Double?
    let diff3h: Double?
    let status: String?
    let locationName: String?
    let latitude: Double?
    let longitude: Double?
    let series: [AtmoPointPayload]?

    enum CodingKeys: String, CodingKey {
        case updatedAt = "updated_at"
        case currentPressure = "current_pressure"
        case diff3h = "diff_3h"
        case status
        case locationName = "location_name"
        case latitude
        case longitude
        case series
    }
}

enum AtmoWidgetStore {
    static let appGroupId = "group.net.iorin.atmoapp.shared"
    static let defaultApiEndpoint = "https://atmo.iorin.net/api/v1/pressure"
    static let defaultLatitude = 35.6895
    static let defaultLongitude = 139.6917

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
        return formatter
    }()

    private static let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "H:00"
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
        return formatter
    }()

    static func loadEntry() -> AtmoEntry {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        let smallImagePath = userDefaults?.string(forKey: "atmo_small_chart")
        let mediumImagePath = userDefaults?.string(forKey: "atmo_medium_chart")
        let hasData = userDefaults?.string(forKey: "current_pressure") != nil
            || userDefaults?.string(forKey: "series_json") != nil
            || userDefaults?.string(forKey: "full_series_json") != nil
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

    /// 最新のタイムラインエントリ一覧と、次回リロード予定日時を取得する。
    ///
    /// 1. まずバックエンドAPIへ非同期通信を行い、最新実測値と未来24時間の予報時系列を取得する。
    /// 2. 通信成功時は取得データをApp Groupへキャッシュ保存し、時系列タイムラインを構築する。
    /// 3. 通信失敗時（オフラインやOS制限）は、App Groupにキャッシュされた時系列からタイムラインを構築する。
    static func fetchTimelineEntries() async -> (entries: [AtmoEntry], nextReload: Date) {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        let locationName = userDefaults?.string(forKey: "location_name") ?? "選択地点"

        let latStr = userDefaults?.string(forKey: "latitude")
        let lonStr = userDefaults?.string(forKey: "longitude")
        let latitude = Double(latStr ?? "") ?? defaultLatitude
        let longitude = Double(lonStr ?? "") ?? defaultLongitude

        let nextReload = Calendar.current.date(
            byAdding: .hour,
            value: 1,
            to: Date()
        ) ?? Date().addingTimeInterval(3600)

        // 1. APIフェッチの試行
        if let payload = await fetchRemoteReport(latitude: latitude, longitude: longitude) {
            saveCache(payload: payload)
            let resolvedName = payload.locationName?.isEmpty == false
                ? payload.locationName!
                : locationName
            let entries = buildTimeline(from: payload, locationName: resolvedName)
            return (entries: entries, nextReload: nextReload)
        }

        // 2. キャッシュからのタイムライン構築（フォールバック）
        if let cachedPayload = loadCachedPayload() {
            let resolvedName = cachedPayload.locationName?.isEmpty == false
                ? cachedPayload.locationName!
                : locationName
            let entries = buildTimeline(from: cachedPayload, locationName: resolvedName)
            if !entries.isEmpty {
                return (entries: entries, nextReload: nextReload)
            }
        }

        // 3. 単一エントリフォールバック
        return (entries: [loadEntry()], nextReload: nextReload)
    }

    private static func fetchRemoteReport(latitude: Double, longitude: Double) async -> AtmoReportPayload? {
        var components = URLComponents(string: defaultApiEndpoint)
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(format: "%.2f", latitude)),
            URLQueryItem(name: "lon", value: String(format: "%.2f", longitude)),
        ]
        guard let url = components?.url else { return nil }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }
            let decoder = JSONDecoder()
            return try decoder.decode(AtmoReportPayload.self, from: data)
        } catch {
            return nil
        }
    }

    private static func buildTimeline(from payload: AtmoReportPayload, locationName: String) -> [AtmoEntry] {
        guard let series = payload.series, !series.isEmpty else {
            return []
        }

        let now = Date()
        var entries: [AtmoEntry] = []

        // 各点の日時をパース
        let parsed: [(date: Date, point: AtmoPointPayload, index: Int)] = series.enumerated().compactMap { index, point in
            guard let date = parseDate(point.time) else { return nil }
            return (date: date, point: point, index: index)
        }

        guard !parsed.isEmpty else {
            return []
        }

        // 直近1時間前〜未来24時間のポイントを抽出
        let validPoints = parsed.filter { $0.date >= now.addingTimeInterval(-3500) }
        let targetPoints = validPoints.isEmpty ? [parsed.last!] : validPoints

        for (order, item) in targetPoints.prefix(24).enumerated() {
            let idx = item.index
            let point = item.point
            let currentPressure = String(format: "%.1f", point.pressure)

            // 3時間前との気圧差
            let diffText: String
            let status: String
            if idx >= 3 {
                let prevPressure = series[idx - 3].pressure
                let delta = point.pressure - prevPressure
                diffText = String(format: "%+.1f", delta)
                if abs(delta) >= 3.0 {
                    status = "caution"
                } else if abs(delta) >= 1.5 {
                    status = "notice"
                } else {
                    status = "normal"
                }
            } else if let payloadDiff = payload.diff3h {
                diffText = String(format: "%+.1f", payloadDiff)
                status = payload.status ?? "normal"
            } else {
                diffText = "—"
                status = "normal"
            }

            // スパークライン用の前後12点 (radius = 12)
            let radius = 12
            let startIndex = max(0, idx - radius)
            let endIndex = min(series.count - 1, idx + radius)
            let windowPressures = series[startIndex...endIndex].map { $0.pressure }
            let currentIndexInWindow = idx - startIndex

            // 最初の1件は過去時間であっても即座にウィジェットへ表示させるため now を割り当てる
            let entryDate = (order == 0 && item.date < now) ? now : item.date

            entries.append(
                AtmoEntry(
                    date: entryDate,
                    hasData: true,
                    locationName: locationName,
                    currentPressure: currentPressure,
                    diff3h: diffText,
                    hourText: hourFormatter.string(from: item.date),
                    status: status,
                    pressures: windowPressures,
                    currentIndex: currentIndexInWindow,
                    smallImagePath: nil,
                    mediumImagePath: nil
                )
            )
        }

        return entries
    }

    private static func saveCache(payload: AtmoReportPayload) {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        if let current = payload.currentPressure {
            userDefaults?.set(String(format: "%.1f", current), forKey: "current_pressure")
        }
        if let diff = payload.diff3h {
            userDefaults?.set(String(format: "%+.1f", diff), forKey: "diff_3h")
        }
        if let status = payload.status {
            userDefaults?.set(status, forKey: "status")
        }
        if let locationName = payload.locationName, !locationName.isEmpty {
            userDefaults?.set(locationName, forKey: "location_name")
        }
        if let series = payload.series {
            let pressures = series.map { $0.pressure }
            if let data = try? JSONSerialization.data(withJSONObject: pressures),
               let json = String(data: data, encoding: .utf8) {
                userDefaults?.set(json, forKey: "series_json")
            }
            if let encoder = try? JSONEncoder().encode(series),
               let json = String(data: encoder, encoding: .utf8) {
                userDefaults?.set(json, forKey: "full_series_json")
            }
        }
    }

    private static func loadCachedPayload() -> AtmoReportPayload? {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        guard let fullJson = userDefaults?.string(forKey: "full_series_json"),
              let data = fullJson.data(using: .utf8) else {
            return nil
        }
        let decoder = JSONDecoder()
        if let series = try? decoder.decode([AtmoPointPayload].self, from: data) {
            let currentStr = userDefaults?.string(forKey: "current_pressure")
            let current = Double(currentStr ?? "")
            let status = userDefaults?.string(forKey: "status")
            let locationName = userDefaults?.string(forKey: "location_name")
            return AtmoReportPayload(
                updatedAt: nil,
                currentPressure: current,
                diff3h: nil,
                status: status,
                locationName: locationName,
                latitude: nil,
                longitude: nil,
                series: series
            )
        }
        return nil
    }

    private static func parseDate(_ string: String) -> Date? {
        if let date = timeFormatter.date(from: string) {
            return date
        }
        let iso = ISO8601DateFormatter()
        return iso.date(from: string)
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
