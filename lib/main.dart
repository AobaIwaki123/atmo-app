import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'api/pressure_api.dart';
import 'models/pressure_report.dart';
import 'widgets/pressure_chart.dart';
import 'widgets/atmo_widget_preview.dart';
import 'services/widget_update_service.dart';
import 'utils/coarse_location.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WidgetUpdateService.initialize();
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
        // Apple HIG: 深いミッドナイトネイビー
        scaffoldBackgroundColor: const Color(0xFF060913),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          surface: Color(0xFF131B2E),
        ),
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
  bool _isUsingCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _reportFuture = _fetchReportWithLocation();
    });
  }

  Future<PressureReport> _fetchReportWithLocation() async {
    PressureReport report;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.reduced,
            timeLimit: Duration(seconds: 4),
          ),
        );
        _isUsingCurrentLocation = true;
        final coarseLat = CoarseLocation.snap(position.latitude);
        final coarseLon = CoarseLocation.snap(position.longitude);
        report = await _api.fetchLatestReport(
          lat: coarseLat,
          lon: coarseLon,
        );
        // ignore: unawaited_futures
        WidgetUpdateService.updateWidgets(report);
        return report;
      }
    } catch (_) {
      // Permission denied or timeout: seamlessly fallback to default Tokyo
    }

    _isUsingCurrentLocation = false;
    report = await _api.fetchLatestReport();
    // ignore: unawaited_futures
    WidgetUpdateService.updateWidgets(report);
    return report;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'atmo',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            letterSpacing: 0.5,
            color: Colors.white70,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.info_circle, size: 20, color: Colors.white70),
            tooltip: 'プライバシーと設計方針',
            onPressed: () => _showPrivacyInfoModal(context),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.arrow_clockwise, size: 20, color: Colors.white70),
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
            return const Center(
              child: CupertinoActivityIndicator(radius: 14, color: Colors.white70),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.exclamationmark_triangle, size: 44, color: Color(0xFFF87171)),
                    const SizedBox(height: 16),
                    Text(
                      'データ取得エラー\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    CupertinoButton.filled(
                      onPressed: _refresh,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: const Text('再試行', style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
            );
          }

          final report = snapshot.data!;
          final isCaution = report.isCaution;
          final cleanMessage = report.statusMessage.replaceAll(RegExp(r'^[⚠️\s]+'), '');

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 580),
                  child: Column(
                    children: [
                      const SizedBox(height: kToolbarHeight + 10),

                      // 【Apple HIG ヒーローセクション: 画面全体を支配する巨大な中央タイポグラフィ】
                      _buildAppleHero(report, cleanMessage, isCaution),
                      const SizedBox(height: 36),

                      // 【Apple Weather 1: 48時間気圧推移モジュール】
                      _buildAppleChartModule(report),
                      const SizedBox(height: 16),

                      // 【Apple Weather 2: 2列スクエア・モジュールグリッド】
                      _buildAppleMetricGrid(report),
                      const SizedBox(height: 24),

                      // 観測メタ情報（控えめなフッター、タップでプライバシー詳細）
                      InkWell(
                        onTap: () => _showPrivacyInfoModal(context),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                report.latitude != null && report.longitude != null
                                    ? '観測エリア: ${report.locationName} (${report.latitude!.toStringAsFixed(1)}°N, ${report.longitude!.toStringAsFixed(1)}°E)'
                                    : '観測エリア: ${report.locationName}',
                                style: const TextStyle(color: Colors.white30, fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              const Icon(CupertinoIcons.info_circle, size: 12, color: Colors.white30),
                              const Text('  •  ', style: TextStyle(color: Colors.white30, fontSize: 12)),
                              Text(
                                '更新: ${_formatTime(report.updatedAt)}',
                                style: const TextStyle(color: Colors.white30, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // 【ホーム画面ウィジェット・プレビュー】
                      _buildWidgetPreviewSection(report),
                      const SizedBox(height: 36),
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

  /// ウィジェットプレビューセクション (Small: 158×158, Medium: 338×158)
  Widget _buildWidgetPreviewSection(PressureReport report) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(CupertinoIcons.square_grid_2x2, size: 15, color: Colors.white54),
              SizedBox(width: 8),
              Text(
                'ホーム画面ウィジェット (プレビュー)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AtmoSmallWidgetView(report: report),
                AtmoMediumWidgetView(report: report),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Apple Weather 純正風ヒーローセクション
  Widget _buildAppleHero(PressureReport report, String message, bool isCaution) {
    final displayName = _isUsingCurrentLocation
        ? (report.locationName.isNotEmpty ? report.locationName : '現在地')
        : (report.locationName.isNotEmpty ? report.locationName : '東京都');

    return Column(
      children: [
        // 地名 / ロケーション表示
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isUsingCurrentLocation) ...[
              const Icon(CupertinoIcons.location_fill, size: 20, color: Colors.white70),
              const SizedBox(width: 6),
            ],
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // 超大型気圧タイポグラフィ (88pt, 薄いウェイト)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              report.currentPressure.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 88,
                fontWeight: FontWeight.w200,
                color: Colors.white,
                letterSpacing: -3.0,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'hPa',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w300,
                color: Colors.white54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 状態サマリー（上品な色合い）
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isCaution
                ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCaution ? CupertinoIcons.exclamationmark_circle_fill : CupertinoIcons.check_mark_circled_solid,
                size: 15,
                color: isCaution ? const Color(0xFFF87171) : const Color(0xFF34D399),
              ),
              const SizedBox(width: 6),
              Text(
                isCaution ? message : '気圧は平常・安定しています',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isCaution ? const Color(0xFFFCA5A5) : const Color(0xFF6EE7B7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Apple Weather 風の半透明チャートモジュール
  Widget _buildAppleChartModule(PressureReport report) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06), // 半透明マテリアル
        borderRadius: BorderRadius.circular(22), // iOS特有のゆったりした角丸
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.chart_bar_alt_fill,
                size: 14,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 6),
              Text(
                '48時間 気圧推移',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          PressureChart(series: report.series),
        ],
      ),
    );
  }

  /// Apple Weather 特有の2列スクエア・モジュールグリッド
  Widget _buildAppleMetricGrid(PressureReport report) {
    final diff = report.diff3h;
    final isUp = diff >= 0;

    return Row(
      children: [
        // 左タイル: 3時間変動
        Expanded(
          child: Container(
            height: 130,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(22),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.arrow_up_down,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '3時間変動',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${isUp ? '+' : ''}${diff.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  diff.abs() >= 2.0 ? '急変注意' : '安定推移',
                  style: TextStyle(
                    color: diff.abs() >= 2.0 ? const Color(0xFFFBBF24) : Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),

        // 右タイル: 気温
        Expanded(
          child: Container(
            height: 130,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(22),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.thermometer,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '気温',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      report.temperature.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Text(
                      '°C',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
                const Text(
                  '現在の観測値',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.month}月${dt.day}日 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  void _showPrivacyInfoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(CupertinoIcons.shield_fill, color: Colors.cyan, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'プライバシー保護の仕組み',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'ゼロ・インプットとピンポイント特定排除の両立',
                            style: TextStyle(fontSize: 12, color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildPrivacyFeatureRow(
                  icon: CupertinoIcons.location_slash,
                  title: 'ピンポイントな居場所は一切取得しません',
                  description:
                      'iOSの仕組みにより、OSレベルで「おおよその位置情報（数キロ四方）」しかアプリに渡されません。生の高精度GPSがアプリに流入することを物理的に遮断しています。',
                ),
                const SizedBox(height: 14),
                _buildPrivacyFeatureRow(
                  icon: CupertinoIcons.square_grid_2x2,
                  title: '約10km四方の固定メッシュにスナップ',
                  description:
                      '気圧は大気現象であり、ピンポイント座標は不要です。端末内で座標を0.1度単位（約10km四方）に丸めてから気圧データを照会します。',
                ),
                const SizedBox(height: 14),
                _buildPrivacyFeatureRow(
                  icon: CupertinoIcons.lock_shield,
                  title: '悪意ある開発者であっても特定不可能',
                  description:
                      '通信ログやサーバーを監視・傍受しても、手に入るのは広域メッシュの代表点のみです。自宅や職場の建物を特定することは原理的に成立しません。',
                ),
                const SizedBox(height: 14),
                _buildPrivacyFeatureRow(
                  icon: CupertinoIcons.checkmark_seal,
                  title: '手動入力の手間はゼロ',
                  description:
                      '市区町村を手動検索・切り替える面倒な操作なく、移動先でも自動で安全に現在地周辺の気圧をご確認いただけます。',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('閉じる', style: TextStyle(color: Colors.white, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrivacyFeatureRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.cyanAccent.shade100),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
