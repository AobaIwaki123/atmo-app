import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'widget_content.dart';
import 'widget_design_tokens.dart';

/// Small/Mediumで共有する軽量グラフ。
class MiniPressureChart extends StatelessWidget {
  final WidgetChartData data;

  const MiniPressureChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MiniPressureChartPainter(data: data),
      child: const SizedBox.expand(),
    );
  }
}

class MiniPressureChartPainter extends CustomPainter {
  final WidgetChartData data;
  final Color lineColor;

  MiniPressureChartPainter({
    required this.data,
    this.lineColor = WidgetColors.graph,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pressures = data.pressures;
    if (pressures.length < 2 || size.isEmpty) return;

    final minPressure = pressures.reduce(min);
    final maxPressure = pressures.reduce(max);
    final range = max(maxPressure - minPressure, 2.0);
    final stepX = size.width / (pressures.length - 1);
    final points = <Offset>[];

    for (var index = 0; index < pressures.length; index++) {
      final normalized = (pressures[index] - minPressure) / range;
      points.add(
        Offset(
          index * stepX,
          size.height * WidgetChartMetrics.plotBottom -
              normalized * size.height * WidgetChartMetrics.plotHeight,
        ),
      );
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: WidgetChartMetrics.fillOpacity),
            Colors.transparent,
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = WidgetChartMetrics.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final index = data.currentIndex;
    if (index < 0 || index >= points.length) return;

    final point = points[index];
    final guidePaint = Paint()
      ..color = WidgetColors.guide
      ..strokeWidth = WidgetChartMetrics.guideStrokeWidth;
    canvas.drawLine(
      Offset(point.dx, WidgetChartMetrics.guideTop),
      Offset(point.dx, size.height),
      guidePaint,
    );

    canvas.drawCircle(
      point,
      WidgetChartMetrics.outerDotRadius,
      Paint()..color = WidgetColors.surface,
    );
    canvas.drawCircle(
      point,
      WidgetChartMetrics.innerDotRadius,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant MiniPressureChartPainter oldDelegate) {
    return oldDelegate.data.currentIndex != data.currentIndex ||
        !listEquals(oldDelegate.data.pressures, data.pressures) ||
        oldDelegate.lineColor != lineColor;
  }
}
