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
        scaffoldBackgroundColor: const Color(0xFF0B1120), // 深いDark Slate
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
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: '更新',
            onPressed: _refresh,
          ),
          const SizedBox(width: 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 580),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // アラートバナー
                      if (isCaution) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.12),
                            border: Border.all(
                              color: Colors.redAccent.withValues(alpha: 0.35),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: Colors.redAccent, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  report.statusMessage,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // 【素朴な標準機能だけで洗練させた計器カード】
                      _buildInstrumentCard(report),
                      const SizedBox(height: 16),

                      // 48h気圧推移チャート (fl_chart)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF151E2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
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
                                    '動的ベジェ曲線',
                                    style: TextStyle(
                                      color: Colors.cyanAccent,
                                      fontSize: 11,
                                    ),
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
                          '観測更新: ${report.updatedAt}',
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 外部依存ゼロ・Flutter標準の素朴な機能（グラデーション、枠線、スケールバー）で構築したカード
  Widget _buildInstrumentCard(PressureReport report) {
    final isCaution = report.isCaution;
    final diff = report.diff3h;
    final isUp = diff >= 0;

    return Container(
      decoration: BoxDecoration(
        // 微細な斜めグラデーション
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF111827),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        // 状態に応じた繊細な境界線
        border: Border.all(
          color: isCaution
              ? Colors.redAccent.withValues(alpha: 0.4)
              : Colors.cyanAccent.withValues(alpha: 0.2),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 上段: 観測地点 ＋ 状態バッジ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 15,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '東京 観測地点',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCaution
                      ? Colors.redAccent.withValues(alpha: 0.15)
                      : Colors.cyanAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCaution
                        ? Colors.redAccent.withValues(alpha: 0.4)
                        : Colors.cyanAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  isCaution ? '急変警戒' : '大気圧安定',
                  style: TextStyle(
                    color: isCaution ? Colors.redAccent : Colors.cyanAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 中段: メイン気圧値 ＋ 3h変動トレンド
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 気圧値
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    report.currentPressure.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'hPa',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),

              // 変動トレンド指標
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '過去3時間の変動',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUp ? Icons.trending_up : Icons.trending_down,
                          size: 18,
                          color: diff.abs() >= 2.0
                              ? Colors.orangeAccent
                              : Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${isUp ? '+' : ''}${diff.toStringAsFixed(1)} hPa',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: diff.abs() >= 2.0
                                ? Colors.orangeAccent
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 下段: 気圧スケールバー（990 〜 1030 hPa 内での現在位置）
          _buildPressureScaleBar(report.currentPressure),
          const SizedBox(height: 12),

          // 最下段: 気温 & 状態インフォ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '低気圧 (頭痛注意)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.thermostat,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  Text(
                    ' 気温 ${report.temperature.toStringAsFixed(0)}°C',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              Text(
                '高気圧 (急変注意)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 990〜1030 hPa の範囲で現在値の位置を示す素朴な水平スケールバー（外部依存ゼロ）
  Widget _buildPressureScaleBar(double currentPressure) {
    const minP = 990.0;
    const maxP = 1030.0;
    final clamped = currentPressure.clamp(minP, maxP);
    final ratio = (clamped - minP) / (maxP - minP);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final indicatorX = (totalWidth * ratio).clamp(6.0, totalWidth - 6.0);

        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            // 背景スケールバー（低気圧: 赤系 ➔ 安定: 青/緑 ➔ 高気圧: オレンジ/赤）
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: LinearGradient(
                  colors: [
                    Colors.redAccent.withValues(alpha: 0.7),
                    Colors.cyanAccent.withValues(alpha: 0.6),
                    Colors.blueAccent.withValues(alpha: 0.6),
                    Colors.orangeAccent.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            // 現在位置のピンマーカー
            Positioned(
              left: indicatorX - 6,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0B1120), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withValues(alpha: 0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
