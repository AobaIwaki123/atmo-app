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
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
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

          // バックエンド文字列に含まれる絵文字（⚠️ 等）を除去してアイコン重複を解消
          final cleanMessage = report.statusMessage.replaceAll(RegExp(r'^[⚠️\s]+'), '');

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
                      // 急変警告バナー (アイコン重複を解消し、しっかりした面と左太ボーダーで整理)
                      if (isCaution) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(12),
                            border: const Border(
                              left: BorderSide(color: Colors.redAccent, width: 4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.redAccent,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  cleanMessage,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // 計器盤カード（細かい文字を削ぎ落とし、太めの枠線と面構成で整理）
                      _buildInstrumentCard(report),
                      const SizedBox(height: 16),

                      // 48h気圧推移チャート (細い枠線を全廃し、面構成で表現)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF151E2E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                              child: Text(
                                '48時間 気圧推移',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            PressureChart(series: report.series),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 最終更新（余計なラベルを省き、控えめに配置）
                      Center(
                        child: Text(
                          '更新: ${_formatTime(report.updatedAt)}',
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
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

  /// 計器カード（細かい文字を全廃し、しっかりしたボーダーと面で表現）
  Widget _buildInstrumentCard(PressureReport report) {
    final isCaution = report.isCaution;
    final diff = report.diff3h;
    final isUp = diff >= 0;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF111827),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        // 細い線をやめ、2.0pxのしっかりしたアクセント枠線を採用
        border: Border.all(
          color: isCaution ? Colors.redAccent : Colors.cyanAccent.withValues(alpha: 0.6),
          width: 2.0,
        ),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 上段: 地点名 ＋ 状態バッジ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '東京',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isCaution ? Colors.redAccent : Colors.cyanAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isCaution ? '急変警戒' : '安定',
                  style: TextStyle(
                    color: isCaution ? Colors.white : Colors.cyanAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 中段: メイン気圧値 ＋ 変動値
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
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'hPa',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),

              // 変動値（細い枠線を無くし、面で力強く表示）
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: diff.abs() >= 2.0
                      ? Colors.orangeAccent.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUp ? Icons.trending_up : Icons.trending_down,
                      size: 22,
                      color: diff.abs() >= 2.0 ? Colors.orangeAccent : Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${isUp ? '+' : ''}${diff.toStringAsFixed(1)} / 3h',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: diff.abs() >= 2.0 ? Colors.orangeAccent : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // 下段: 太く見やすくなった気圧スケールバー
          _buildPressureScaleBar(report.currentPressure),
          const SizedBox(height: 14),

          // 最下段: 気温のみシンプルに表示（細かい注釈は全廃）
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.thermostat,
                size: 16,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                '${report.temperature.toStringAsFixed(0)}°C',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 990〜1030 hPa スケールバー（高さを8pxに太くし、ドットを16pxに拡大）
  Widget _buildPressureScaleBar(double currentPressure) {
    const minP = 990.0;
    const maxP = 1030.0;
    final clamped = currentPressure.clamp(minP, maxP);
    final ratio = (clamped - minP) / (maxP - minP);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final indicatorX = (totalWidth * ratio).clamp(8.0, totalWidth - 8.0);

        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            // 太めのスケールバー (高さ8px)
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                  colors: [
                    Colors.redAccent,
                    Colors.cyanAccent,
                    Colors.blueAccent,
                    Colors.orangeAccent,
                  ],
                ),
              ),
            ),
            // 大きめのピンマーカー (16px)
            Positioned(
              left: indicatorX - 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0B1120), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
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

  String _formatTime(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}
