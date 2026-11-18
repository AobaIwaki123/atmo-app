import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'mini_pressure_chart.dart';
import 'widget_content.dart';
import 'widget_design_tokens.dart';

IconData _trendIconForDiff(String signedDiff) {
  if (signedDiff.startsWith('+')) {
    return CupertinoIcons.arrow_up_right;
  }
  if (signedDiff.startsWith('-')) {
    return CupertinoIcons.arrow_down_right;
  }
  return CupertinoIcons.arrow_right;
}

/// iOSロック画面・インライン（時計上1行）ウィジェットのプレビュー。
class AtmoLockInlineWidgetView extends StatelessWidget {
  final WidgetContent content;

  const AtmoLockInlineWidgetView({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final pressureText = content.currentPressure.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: WidgetSpacing.accessoryInlineHorizontal,
        vertical: WidgetSpacing.accessoryInlineVertical,
      ),
      decoration: BoxDecoration(
        color: WidgetColors.accessorySurface,
        borderRadius: BorderRadius.circular(WidgetMetrics.accessoryInlineRadius),
        border: Border.all(color: WidgetColors.accessoryBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.gauge,
            size: WidgetMetrics.accessoryInlineIcon,
            color: WidgetColors.primaryText,
          ),
          const SizedBox(width: WidgetSpacing.accessoryInlineGap),
          Flexible(
            child: Text(
              '${content.locationName} ${pressureText}hPa (${content.signedDiffText})',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: WidgetTypography.accessoryInline,
            ),
          ),
        ],
      ),
    );
  }
}

/// iOSロック画面・円形（accessoryCircular）ウィジェットのプレビュー。
class AtmoLockCircularWidgetView extends StatelessWidget {
  final WidgetContent content;

  const AtmoLockCircularWidgetView({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final pressureText = content.currentPressure.toStringAsFixed(1);

    return SizedBox(
      width: WidgetMetrics.accessoryCircularSize,
      height: WidgetMetrics.accessoryCircularSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: WidgetColors.accessorySurface,
          shape: BoxShape.circle,
          border: Border.all(color: WidgetColors.accessoryBorder),
        ),
        child: CustomPaint(
          painter: _AccessoryCircularGaugePainter(
            pressure: content.currentPressure,
          ),
          child: Padding(
            padding: const EdgeInsets.all(WidgetMetrics.accessoryGaugeStroke * 1.5),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        pressureText,
                        style: WidgetTypography.accessoryCircularPressure,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _trendIconForDiff(content.signedDiffText),
                            size: WidgetMetrics.accessoryCircularDeltaIcon,
                            color: WidgetColors.primaryText,
                          ),
                          const SizedBox(
                            width: WidgetSpacing.accessoryCircularDeltaGap,
                          ),
                          Text(
                            content.signedDiffText,
                            maxLines: 1,
                            style: WidgetTypography.accessoryCircularDelta,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Text('気圧', style: WidgetTypography.accessoryGaugeLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccessoryCircularGaugePainter extends CustomPainter {
  final double pressure;

  const _AccessoryCircularGaugePainter({required this.pressure});

  @override
  void paint(Canvas canvas, Size size) {
    const startAngle = 135 * pi / 180;
    const sweepAngle = 270 * pi / 180;
    const inset = WidgetMetrics.accessoryGaugeStroke * 0.9;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );

    final trackPaint = Paint()
      ..color = WidgetColors.accessoryTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = WidgetMetrics.accessoryGaugeStroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);

    final progress =
        ((pressure - WidgetMetrics.pressureGaugeMin) /
                (WidgetMetrics.pressureGaugeMax -
                    WidgetMetrics.pressureGaugeMin))
            .clamp(0.0, 1.0);

    final activePaint = Paint()
      ..color = WidgetColors.primaryText
      ..style = PaintingStyle.stroke
      ..strokeWidth = WidgetMetrics.accessoryGaugeStroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, activePaint);

    final angle = startAngle + sweepAngle * progress;
    final radius = rect.width / 2;
    final dotCenter = Offset(
      rect.center.dx + radius * cos(angle),
      rect.center.dy + radius * sin(angle),
    );
    canvas.drawCircle(
      dotCenter,
      WidgetMetrics.accessoryGaugeDotRadius,
      Paint()..color = WidgetColors.primaryText,
    );
  }

  @override
  bool shouldRepaint(covariant _AccessoryCircularGaugePainter oldDelegate) {
    return oldDelegate.pressure != pressure;
  }
}

/// iOSロック画面・長方形（accessoryRectangular）ウィジェットのプレビュー。
class AtmoLockRectangularWidgetView extends StatelessWidget {
  final WidgetContent content;

  const AtmoLockRectangularWidgetView({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final pressureText = content.currentPressure.toStringAsFixed(1);

    return SizedBox(
      width: WidgetMetrics.accessoryRectangularWidth,
      height: WidgetMetrics.accessoryRectangularHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: WidgetColors.accessorySurface,
          borderRadius: BorderRadius.circular(
            WidgetMetrics.accessoryRectangularRadius,
          ),
          border: Border.all(color: WidgetColors.accessoryBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: WidgetSpacing.accessoryCardHorizontal,
            vertical: WidgetSpacing.accessoryCardVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.map_pin,
                    size: WidgetMetrics.accessoryTitleIcon,
                    color: WidgetColors.primaryText,
                  ),
                  const SizedBox(width: WidgetSpacing.iconToText),
                  Expanded(
                    child: Text(
                      content.locationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: WidgetTypography.accessoryTitle,
                    ),
                  ),
                  const SizedBox(width: WidgetSpacing.iconToText),
                  Icon(
                    _trendIconForDiff(content.signedDiffText),
                    size: WidgetMetrics.accessoryDeltaIcon,
                    color: WidgetColors.primaryText,
                  ),
                  const SizedBox(width: WidgetSpacing.accessoryDeltaGap),
                  Text(
                    content.signedDiffText,
                    style: WidgetTypography.accessoryDelta,
                  ),
                ],
              ),
              const SizedBox(height: WidgetSpacing.accessoryStack),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth:
                            WidgetMetrics.accessoryRectangularPressureMaxWidth,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.bottomLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              pressureText,
                              style: WidgetTypography.accessoryPressure,
                            ),
                            const SizedBox(
                              width: WidgetSpacing.accessoryDeltaGap,
                            ),
                            const Text(
                              'hPa',
                              style: WidgetTypography.accessoryUnit,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: WidgetSpacing.accessoryRectangularGap,
                    ),
                    Expanded(
                      child: MiniPressureChart(
                        data: content.chartData(
                          radius: WidgetMetrics.smallChartRadius,
                        ),
                        lineColor: WidgetColors.primaryText,
                        dotBackgroundColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
