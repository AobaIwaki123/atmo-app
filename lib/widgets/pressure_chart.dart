import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/pressure_report.dart';

class PressureChart extends StatelessWidget {
  final List<PressurePoint> series;

  const PressureChart({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Text('データがありません', style: TextStyle(color: Colors.white38)),
        ),
      );
    }

    // Y軸の最小・最大値を計算（マージンを持たせる）
    var minP = series.first.pressure;
    var maxP = series.first.pressure;
    int currentIndex = -1;

    for (var i = 0; i < series.length; i++) {
      final p = series[i].pressure;
      if (p < minP) minP = p;
      if (p > maxP) maxP = p;
      if (series[i].isCurrent) currentIndex = i;
    }

    final minY = (minP - 2.0).floorToDouble();
    final maxY = (maxP + 2.0).ceilToDouble();

    final spots = <FlSpot>[];
    for (var i = 0; i < series.length; i++) {
      spots.add(FlSpot(i.toDouble(), series[i].pressure));
    }

    return SizedBox(
      height: 230,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (series.length - 1).toDouble(),
            minY: minY,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 2,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.white.withValues(alpha: 0.06),
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 42,
                  interval: 4,
                  getTitlesWidget: (value, meta) {
                    if (value == minY || value == maxY) return const SizedBox.shrink();
                    return Text(
                      '${value.toInt()}',
                      style: const TextStyle(color: Colors.white38, fontSize: 10),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  interval: 6, // 6時間おきにラベル表示
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= series.length) return const SizedBox.shrink();
                    final timeStr = series[idx].time;
                    // "2026-10-14T18:00" -> "18:00"
                    final hourStr = timeStr.contains('T')
                        ? timeStr.split('T').last.substring(0, 5)
                        : timeStr;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        hourStr,
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (spot) => const Color(0xFF0F172A),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final idx = spot.x.toInt();
                    final point = series[idx];
                    return LineTooltipItem(
                      '${point.time.replaceFirst('T', ' ')}\n',
                      const TextStyle(color: Colors.white60, fontSize: 11),
                      children: [
                        TextSpan(
                          text: '${point.pressure.toStringAsFixed(1)} hPa',
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.35,
                color: Colors.cyanAccent,
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  checkToShowDot: (spot, barData) {
                    // 現在時刻の点のみドットを表示
                    return spot.x.toInt() == currentIndex;
                  },
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 5,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: Colors.cyanAccent,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.cyanAccent.withValues(alpha: 0.25),
                      Colors.cyanAccent.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
