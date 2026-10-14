import 'package:flutter/material.dart';
import 'api/pressure_api.dart';
import 'models/pressure_report.dart';
import 'widgets/pressure_chart.dart';

void main() {
  runApp(const AtmoApp());
}

class AtmoApp extends StatelessWidget {
  const AtmoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'atmo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.cyan,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
      ),
      home: const PressureMonitorPage(),
    );
  }
}

class PressureMonitorPage extends StatefulWidget {
  const PressureMonitorPage({super.key});

  @override
  State<PressureMonitorPage> createState() => _PressureMonitorPageState();
}

class _PressureMonitorPageState extends State<PressureMonitorPage> {
  final PressureApi _api = PressureApi();
  late Future<PressureReport> _reportFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _reportFuture = _api.fetchLatestReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'atmo',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '更新',
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<PressureReport>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(
                      'データ取得エラー\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('再試行'),
                    ),
                  ],
                ),
              ),
            );
          }

          final report = snapshot.data!;
          final isCaution = report.isCaution;

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // アラートバナー
                    if (isCaution) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.15),
                          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                report.statusMessage,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 現在値カード
                    Card(
                      color: const Color(0xFF1E293B), // Slate 800
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFF334155)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '東京（現在値）',
                              style: TextStyle(color: Colors.white60, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  report.currentPressure.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'hPa',
                                  style: TextStyle(fontSize: 18, color: Colors.white60),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildMetricChip(
                                  label: '3h変動',
                                  value: '${report.diff3h >= 0 ? '+' : ''}${report.diff3h.toStringAsFixed(1)} hPa',
                                  isHighlight: report.diff3h.abs() >= 2.0,
                                ),
                                const SizedBox(width: 12),
                                _buildMetricChip(
                                  label: '気温',
                                  value: '${report.temperature.toStringAsFixed(0)} °C',
                                  isHighlight: false,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 48h気圧推移チャート (fl_chart 動的ベジェ曲線)
                    Card(
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFF334155)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '48時間 気圧推移',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'fl_chart (動的曲線)',
                                  style: TextStyle(color: Colors.cyanAccent, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          PressureChart(series: report.series),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 最終更新
                    Center(
                      child: Text(
                        '更新: ${report.updatedAt}',
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricChip({
    required String label,
    required String value,
    required bool isHighlight,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlight
            ? Colors.orangeAccent.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHighlight
              ? Colors.orangeAccent.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: isHighlight ? Colors.orangeAccent : Colors.white60,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.orangeAccent : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
