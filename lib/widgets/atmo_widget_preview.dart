import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/pressure_report.dart';

/// ウィジェット用の正時 (HH:00) フォーマットヘルパー
String formatToHourZero(String isoTime) {
  try {
    final dt = DateTime.parse(isoTime).toLocal();
    final hourStr = dt.hour.toString().padLeft(2, '0');
    return '$hourStr:00';
  } catch (_) {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:00';
  }
}

/// ウィジェット専用の超軽量スパークライン・ベジェ曲線 Painter
class MiniPressureChartPainter extends CustomPainter {
  final List<double> pressures;
  final int currentIndex;
  final Color lineColor;
  final Color currentDotColor;

  MiniPressureChartPainter({
    required this.pressures,
    required this.currentIndex,
    this.lineColor = const Color(0xFF38BDF8),
    this.currentDotColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pressures.isEmpty) return;

    final minP = pressures.reduce(min);
    final maxP = pressures.reduce(max);
    final rangeP = (maxP - minP) < 2.0 ? 2.0 : (maxP - minP);

    final width = size.width;
    final height = size.height;
    final stepX = pressures.length > 1 ? width / (pressures.length - 1) : 0.0;

    final points = <Offset>[];
    for (int i = 0; i < pressures.length; i++) {
      final normY = (pressures[i] - minP) / rangeP;
      // y座標は反転（高い気圧が上、余白を上下に10%設ける）
      final y = height * 0.85 - (normY * (height * 0.7));
      final x = i * stepX;
      points.add(Offset(x, y));
    }

    // ベジェ曲線の描画
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    // 塗りつぶしグラデーション
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, height)
      ..lineTo(points.first.dx, height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.35),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // 線の描画
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // 現在地点のドット & 縦ガイドライン
    if (currentIndex >= 0 && currentIndex < points.length) {
      final currentPoint = points[currentIndex];

      // 薄い縦ガイドライン
      final guidePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..strokeWidth = 1.0;
      canvas.drawLine(
        Offset(currentPoint.dx, 4),
        Offset(currentPoint.dx, height),
        guidePaint,
      );

      // 外枠ドット
      final dotBgPaint = Paint()
        ..color = const Color(0xFF0C1322)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(currentPoint, 4.0, dotBgPaint);

      // 中身ドット
      final dotPaint = Paint()
        ..color = currentDotColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(currentPoint, 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MiniPressureChartPainter oldDelegate) {
    return oldDelegate.pressures != pressures ||
        oldDelegate.currentIndex != currentIndex;
  }
}

/// Small ウィジェット (158×158: グラフ主役の正方形ミニマル)
class AtmoSmallWidgetView extends StatelessWidget {
  final PressureReport report;

  const AtmoSmallWidgetView({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final statusColor = report.isCaution
        ? const Color(0xFFF87171)
        : (report.status == 'notice' ? const Color(0xFFFBBF24) : const Color(0xFF38BDF8));

    // 過去12h + 未来12h の気圧データを抽出
    final series = report.series;
    int currentIdx = series.indexWhere((p) => p.isCurrent);
    if (currentIdx == -1) currentIdx = series.length ~/ 2;

    final startIdx = max(0, currentIdx - 12);
    final endIdx = min(series.length, currentIdx + 13);
    final displaySeries = series.sublist(startIdx, endIdx);
    final pressures = displaySeries.map((p) => p.pressure).toList();
    final localCurrentIdx = currentIdx - startIdx;

    final hourText = formatToHourZero(report.updatedAt);
    final locationText = report.locationName.isNotEmpty ? report.locationName : '現在地';

    return Container(
      width: 158,
      height: 158,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー: 地名/区市名 + 観測正時 + 状態インジケーター
          Row(
            children: [
              const Icon(CupertinoIcons.location_fill, size: 11, color: Colors.white60),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  locationText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Text(
                hourText,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(width: 5),
              // ワンポイント・ステータスインジケーター
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // 現在気圧の控えめな表示 (主役のグラフを邪魔しない)
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                report.currentPressure.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 3),
              const Text(
                'hPa',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Colors.white38,
                ),
              ),
              const Spacer(),
              Text(
                '${report.diff3h >= 0 ? "+" : ""}${report.diff3h.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ],
          ),

          // 主役のベジェ曲線グラフ（残り領域をすべて使用）
          Expanded(
            child: ClipRect(
              child: CustomPaint(
                size: Size.infinite,
                painter: MiniPressureChartPainter(
                  pressures: pressures,
                  currentIndex: localCurrentIdx,
                  lineColor: statusColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Medium ウィジェット (338×158: ワイドなグラフ主役の横長ウィジェット)
class AtmoMediumWidgetView extends StatelessWidget {
  final PressureReport report;

  const AtmoMediumWidgetView({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final statusColor = report.isCaution
        ? const Color(0xFFF87171)
        : (report.status == 'notice' ? const Color(0xFFFBBF24) : const Color(0xFF38BDF8));

    final series = report.series;
    int currentIdx = series.indexWhere((p) => p.isCurrent);
    if (currentIdx == -1) currentIdx = series.length ~/ 2;

    final startIdx = max(0, currentIdx - 18);
    final endIdx = min(series.length, currentIdx + 19);
    final displaySeries = series.sublist(startIdx, endIdx);
    final pressures = displaySeries.map((p) => p.pressure).toList();
    final localCurrentIdx = currentIdx - startIdx;

    final hourText = formatToHourZero(report.updatedAt);
    final locationText = report.locationName.isNotEmpty ? report.locationName : '現在地';

    return Container(
      width: 338,
      height: 158,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // 左側: 市区町村名、正時、現在気圧、3h変動
          SizedBox(
            width: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(CupertinoIcons.location_fill, size: 12, color: Colors.white60),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            locationText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hourText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          report.currentPressure.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w200,
                            color: Colors.white,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Text(
                          'hPa',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '3h: ${report.diff3h >= 0 ? "+" : ""}${report.diff3h.toStringAsFixed(1)} hPa',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 右側: ワイドな気圧推移ベジェ曲線グラフ（主役）
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRect(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: MiniPressureChartPainter(
                        pressures: pressures,
                        currentIndex: localCurrentIdx,
                        lineColor: statusColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('-12h', style: TextStyle(color: Colors.white24, fontSize: 9)),
                    Text('現在', style: TextStyle(color: Colors.white38, fontSize: 9)),
                    Text('+12h', style: TextStyle(color: Colors.white24, fontSize: 9)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
