import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pressure_report.dart';

class PressureApi {
  static const String defaultEndpoint = 'https://atmo.aooba.net/api/v1/pressure';

  final String endpoint;
  final http.Client _client;

  PressureApi({
    this.endpoint = defaultEndpoint,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<PressureReport> fetchLatestReport({double? lat, double? lon}) async {
    Uri uri = Uri.parse(endpoint);
    if (lat != null && lon != null) {
      uri = uri.replace(queryParameters: {
        'lat': lat.toStringAsFixed(4),
        'lon': lon.toStringAsFixed(4),
      });
    }

    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch pressure data: HTTP ${response.statusCode}');
    }

    final decoded = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return PressureReport(decoded);
  }
}
