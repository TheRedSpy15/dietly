import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafp/models/historydata.dart';

import '../../charts/weeklyPointsChart.dart';
import '../../providers/providers.dart';
import '../meals/nutritionStats.dart';

class Charts extends ConsumerWidget {
  const Charts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthData = ref.watch(healthProvider);
    final historyData = ref.watch(historyProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Charts'),
        ),
        body: historyData.when(
          data: (history) {
            return ListView(
              children: [
                Card(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8.0, 2, 8.0, 0.0),
                        child: Text("Used points past Week",
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8.0, 2, 8.0, 8.0),
                        child: Text("Today starting from the right",
                            textAlign: TextAlign.center),
                      ),
                      WeeklyPointsChart(
                        yValues: HistoryData.getPointsFromPastWeek(history),
                      ),
                    ],
                  ),
                ),
                NutritionStatsCard(data: history),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text(err.toString())),
        ));
  }
}
