import 'package:flutter/cupertino.dart';

import 'mini_pressure_chart.dart';
import 'widget_content.dart';
import 'widget_design_tokens.dart';

/// iOS/Android Mediumウィジェットの構成。
class AtmoMediumWidgetView extends StatelessWidget {
  final WidgetContent content;

  const AtmoMediumWidgetView({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final statusColor = widgetStatusColor(content.status);

    return SizedBox(
      width: WidgetMetrics.mediumWidth,
      height: WidgetMetrics.mediumHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: WidgetColors.surface,
          borderRadius: BorderRadius.circular(WidgetMetrics.cardRadius),
          border: Border.all(color: WidgetColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: WidgetSpacing.mediumHorizontal,
            vertical: WidgetSpacing.mediumTop,
          ),
          child: Row(
            children: [
              SizedBox(
                width: WidgetMetrics.mediumInfoWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.map_pin_ellipse,
                              size: WidgetMetrics.mediumIcon,
                              color: WidgetColors.secondaryText,
                            ),
                            const SizedBox(width: WidgetSpacing.iconToText),
                            Expanded(
                              child: Text(
                                content.locationName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: WidgetTypography.locationMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: WidgetMetrics.mediumMetadataTop),
                        Text(
                          content.hourText,
                          style: WidgetTypography.timestamp,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                content.currentPressure.toStringAsFixed(1),
                                style: WidgetTypography.pressureMedium,
                              ),
                              const SizedBox(width: WidgetSpacing.iconToText),
                              const Text('hPa', style: WidgetTypography.unit),
                            ],
                          ),
                        ),
                        const SizedBox(height: WidgetMetrics.mediumMetadataTop),
                        Text(
                          '3h ${content.signedDiffText}',
                          style: WidgetTypography.delta(statusColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: WidgetMetrics.mediumColumnGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: MiniPressureChart(
                        data: content.chartData(
                          radius: WidgetMetrics.mediumChartRadius,
                        ),
                      ),
                    ),
                    const SizedBox(height: WidgetMetrics.mediumChartStackGap),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('-12h', style: WidgetTypography.axis),
                        Text('現在', style: WidgetTypography.axis),
                        Text('+12h', style: WidgetTypography.axis),
                      ],
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
