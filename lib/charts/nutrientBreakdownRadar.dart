import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/meals/nutritionStats.dart';
import 'chartStyles.dart';

class NutrientBreakDownRadar extends ConsumerWidget {
  final gridColor = ChartColors.contentColorPurple;
  final titleColor = ChartColors.contentColorPurple;

  final fashionColor = ChartColors.contentColorRed;
  final artColor = ChartColors.contentColorCyan;
  final boxingColor = ChartColors.contentColorGreen;
  final entertainmentColor = ChartColors.contentColorWhite;
  final offRoadColor = ChartColors.contentColorYellow;
  final double angleValue = 0;

  final bool relativeAngleMode = false;
  const NutrientBreakDownRadar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1.3,
            child: RadarChart(
              RadarChartData(
                dataSets: showingDataSets(RawDataSet(
                  title: 'Macros',
                  color: fashionColor,
                  values: [
                    ref.watch(carbsProvider) * 4,
                    ref.watch(proteinProvider) * 4,
                    ref.watch(fatProvider) * 9,
                  ],
                )),
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: const BorderSide(color: Colors.transparent),
                titlePositionPercentageOffset: 0.2,
                titleTextStyle: const TextStyle(fontSize: 14),
                getTitle: (index, angle) {
                  final usedAngle =
                      relativeAngleMode ? angle + angleValue : angleValue;
                  switch (index) {
                    case 0:
                      return RadarChartTitle(
                        text: "Carbs ${ref.watch(carbsProvider).round()}g",
                        angle: usedAngle,
                      );
                    case 1:
                      return RadarChartTitle(
                        text: "Protein ${ref.watch(proteinProvider).round()}g",
                        angle: usedAngle,
                      );
                    case 2:
                      return RadarChartTitle(
                        text: "Fat ${ref.watch(fatProvider).round()}",
                        angle: usedAngle,
                      );
                    default:
                      return const RadarChartTitle(text: '');
                  }
                },
                tickCount: 1,
                ticksTextStyle:
                    const TextStyle(color: Colors.transparent, fontSize: 10),
                tickBorderData: const BorderSide(color: Colors.transparent),
                gridBorderData: BorderSide(color: gridColor, width: 2),
              ),
              swapAnimationDuration: const Duration(milliseconds: 400),
            ),
          ),
        ],
      ),
    );
  }

  List<RadarDataSet> showingDataSets(RawDataSet dataSet) {
    final radarData = RadarDataSet(
      fillColor: dataSet.color.withOpacity(0.2),
      borderColor: dataSet.color,
      entryRadius: 3,
      dataEntries: dataSet.values.map((e) => RadarEntry(value: e)).toList(),
      borderWidth: 2.3,
    );

    return [radarData];
  }
}

class RawDataSet {
  final String title;

  final Color color;
  final List<double> values;
  RawDataSet({
    required this.title,
    required this.color,
    required this.values,
  });
}
