import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'api/pressure_api.dart';
import 'models/location_option.dart';
import 'models/pressure_report.dart';
import 'widgets/pressure_chart.dart';
import 'widgets/atmo_widget_preview.dart';
import 'services/location_selection_store.dart';
import 'services/widget_update_service.dart';

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
      title: 'ソラケア',
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
  const PressureMonitorPage({super.key, this.api});

  final PressureApi? api;

  @override
  State<PressureMonitorPage> createState() => _PressureMonitorPageState();
}

class _PressureMonitorPageState extends State<PressureMonitorPage> {
  late final PressureApi _api = widget.api ?? PressureApi();
  late Future<PressureReport> _reportFuture;
  LocationOption _selectedPlace = LocationCatalog.tokyo;

  @override
  void initState() {
    super.initState();
    _reportFuture = _loadInitialReport();
  }

  void _refresh() {
    setState(() {
      _reportFuture = _fetchReport(_selectedPlace);
    });
  }

  Future<PressureReport> _loadInitialReport() async {
    final savedPlace = await LocationSelectionStore.load();
    final place = savedPlace ?? _selectedPlace;
    if (mounted && savedPlace != null) {
      setState(() => _selectedPlace = savedPlace);
    }
    return _fetchReport(place);
  }

  Future<PressureReport> _fetchReport(LocationOption place) async {
    final report = (await _api.fetchLatestReport(
      latitude: place.latitude,
      longitude: place.longitude,
    )).withLocationName(place.prefecture);
    // ignore: unawaited_futures
    WidgetUpdateService.updateWidgets(report);
    return report;
  }

  void _selectPlace(LocationOption place) {
    setState(() {
      _selectedPlace = place;
      _reportFuture = _fetchReport(place);
    });
    unawaited(LocationSelectionStore.save(place));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'ソラケア',
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
            icon: const Icon(
              CupertinoIcons.info_circle,
              size: 20,
              color: Colors.white70,
            ),
            tooltip: 'プライバシーについて',
            onPressed: () => _showPrivacyInfoModal(context),
          ),
          IconButton(
            icon: const Icon(
              CupertinoIcons.arrow_clockwise,
              size: 20,
              color: Colors.white70,
            ),
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
              child: CupertinoActivityIndicator(
                radius: 14,
                color: Colors.white70,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.exclamationmark_triangle,
                      size: 44,
                      color: Color(0xFFF87171),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'データ取得エラー\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    CupertinoButton.filled(
                      onPressed: _refresh,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: const Text('再試行', style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
            );
          }

          final report = snapshot.data!;
          final isCaution = report.isCaution;
          final cleanMessage = report.statusMessage.replaceAll(
            RegExp(r'^[⚠️\s]+'),
            '',
          );

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
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

                      // 選択地点（タップで地点選択画面を表示）
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => _showLocationPicker(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B)
                                  .withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  CupertinoIcons.map_pin_ellipse,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '選択地点: ${_selectedPlace.prefecture}（${_selectedPlace.representative}）',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  CupertinoIcons.chevron_forward,
                                  size: 12,
                                  color: Colors.white54,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '更新: ${_formatTime(report.updatedAt)}',
                        style: const TextStyle(
                          color: Colors.white30,
                          fontSize: 11,
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
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                CupertinoIcons.square_grid_2x2,
                size: 15,
                color: Colors.white54,
              ),
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
  Widget _buildAppleHero(
    PressureReport report,
    String message,
    bool isCaution,
  ) {
    final displayName = _selectedPlace.prefecture;

    return Column(
      children: [
        // 地名 / ロケーション表示
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.map_pin_ellipse,
              size: 20,
              color: Colors.white70,
            ),
            const SizedBox(width: 6),
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
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
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
                isCaution
                    ? CupertinoIcons.exclamationmark_circle_fill
                    : CupertinoIcons.check_mark_circled_solid,
                size: 15,
                color: isCaution
                    ? const Color(0xFFF87171)
                    : const Color(0xFF34D399),
              ),
              const SizedBox(width: 6),
              Text(
                isCaution ? message : '気圧は平常・安定しています',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isCaution
                      ? const Color(0xFFFCA5A5)
                      : const Color(0xFF6EE7B7),
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
                    color: diff.abs() >= 2.0
                        ? const Color(0xFFFBBF24)
                        : Colors.white54,
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

  void _showLocationPicker(BuildContext context) {
    final searchController = TextEditingController();
    String? prefectureFilter;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final results = LocationCatalog.search(
              searchController.text,
              prefecture: prefectureFilter,
            );
            final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 12 + bottomInset),
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.78,
                  child: Column(
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
                      const SizedBox(height: 18),
                      const Text(
                        '地点を選択',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '都道府県の代表地点から気圧を表示します。',
                        style: TextStyle(fontSize: 12, color: Colors.white60),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String?>(
                        initialValue: prefectureFilter,
                        decoration: InputDecoration(
                          labelText: '都道府県',
                          labelStyle: const TextStyle(color: Colors.white60),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.06),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        dropdownColor: const Color(0xFF1E293B),
                        items: <DropdownMenuItem<String?>>[
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('すべての都道府県'),
                          ),
                          ...LocationCatalog.all.map(
                            (option) => DropdownMenuItem<String?>(
                              value: option.prefecture,
                              child: Text(option.prefecture),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            setModalState(() => prefectureFilter = value),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: searchController,
                        onChanged: (_) => setModalState(() {}),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: '都道府県名・代表地点名で検索',
                          hintStyle: const TextStyle(color: Colors.white38),
                          prefixIcon: const Icon(
                            CupertinoIcons.search,
                            color: Colors.white54,
                          ),
                          suffixIcon: searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(
                                    CupertinoIcons.clear,
                                    color: Colors.white54,
                                  ),
                                  onPressed: () {
                                    searchController.clear();
                                    setModalState(() {});
                                  },
                                ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.06),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: results.isEmpty
                            ? const Center(
                                child: Text(
                                  '該当する地点がありません',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              )
                            : ListView.separated(
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                itemCount: results.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(
                                      color: Colors.white12,
                                      height: 1,
                                    ),
                                itemBuilder: (context, index) {
                                  final option = results[index];
                                  final isSelected =
                                      option.prefecture ==
                                      _selectedPlace.prefecture;
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    leading: Icon(
                                      isSelected
                                          ? CupertinoIcons
                                                .check_mark_circled_solid
                                          : CupertinoIcons.map_pin,
                                      color: isSelected
                                          ? const Color(0xFF34D399)
                                          : Colors.white54,
                                    ),
                                    title: Text(
                                      option.prefecture,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '代表地点: ${option.representative}',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.of(sheetContext).pop();
                                      _selectPlace(option);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(searchController.dispose);
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
                const Text(
                  '地点設定とプライバシー',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '本アプリは端末の位置情報サービス、GPS、バックグラウンド追跡を使用しません。都道府県の代表地点を選択し、その地点の気圧データを取得します。地点の選択内容は端末内に保存され、アカウントや広告識別子には関連付けません。',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'データ提供元',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                const SelectableText(
                  '気象データ: Open-Meteo (CC BY 4.0)\n地名データ: © OpenStreetMap contributors',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      '閉じる',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
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
}
