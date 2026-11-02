import 'package:flutter/cupertino.dart';

import 'mini_pressure_chart.dart';
import 'widget_content.dart';
import 'widget_design_tokens.dart';

/// iOS/Android Smallウィジェットの構成。
class AtmoSmallWidgetView extends StatelessWidget {
  final WidgetContent content;

  const AtmoSmallWidgetView({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final statusColor = widgetStatusColor(content.status);

    return SizedBox(
      width: WidgetMetrics.smallWidth,
      height: WidgetMetrics.smallHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: WidgetColors.surface,
          borderRadius: BorderRadius.circular(WidgetMetrics.cardRadius),
          border: Border.all(color: WidgetColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: WidgetSpacing.smallHorizontal,
            vertical: WidgetSpacing.smallTop,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.map_pin_ellipse,
                    size: WidgetMetrics.smallIcon,
                    color: WidgetColors.secondaryText,
                  ),
                  const SizedBox(width: WidgetSpacing.iconToText),
                  Expanded(
                    child: Text(
                      content.locationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: WidgetTypography.location,
                    ),
                  ),
                  const SizedBox(width: WidgetSpacing.iconToText),
                  Text(content.hourText, style: WidgetTypography.timestamp),
                  const SizedBox(width: WidgetSpacing.iconToText),
                  Container(
                    width: WidgetMetrics.statusDot,
                    height: WidgetMetrics.statusDot,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: WidgetSpacing.section),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      content.currentPressure.toStringAsFixed(1),
                      style: WidgetTypography.pressure,
                    ),
                    const SizedBox(width: WidgetSpacing.iconToText),
                    const Text('hPa', style: WidgetTypography.unit),
                    const SizedBox(width: WidgetSpacing.section),
                    Text(
                      content.signedDiffText,
                      style: WidgetTypography.delta(statusColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: WidgetSpacing.chart),
              Expanded(
                child: MiniPressureChart(
                  data: content.chartData(
                    radius: WidgetMetrics.smallChartRadius,
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
