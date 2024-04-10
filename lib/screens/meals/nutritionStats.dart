import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafp/models/historydata.dart';

import '../../charts/nutrientBreakdownRadar.dart';

final caloriesProvider = StateProvider<double>((ref) => 0);
final carbsProvider = StateProvider<double>((ref) => 0);
final fatProvider = StateProvider<double>((ref) => 0);
final pointsProvider = StateProvider<double>((ref) => 0);
final proteinProvider = StateProvider<double>((ref) => 0);
final todayOnlyProvider = StateProvider<bool>((ref) => true);

class NutritionStatsCard extends ConsumerWidget {
  List<HistoryData> data = [];

  NutritionStatsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();

    // default to today
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.watch(todayOnlyProvider.notifier).state) {
        setBreakDownToday(today, ref);
      }
    });

    return Card(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            ref.watch(todayOnlyProvider)
                ? 'Today\'s nutrition'
                : 'Past 7 Days nutrition',
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: Text(
            'Calories: ${ref.watch(caloriesProvider)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            textAlign: TextAlign.center,
          ),
        ),
        const NutrientBreakDownRadar(),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: OutlinedButton(
            child: Text(ref.watch(todayOnlyProvider.notifier).state
                ? 'Show Past 7 Days'
                : 'Show Today Only'),
            onPressed: () {
              if (ref.watch(todayOnlyProvider.notifier).state) {
                setBreakDownToday(today, ref);
              } else {
                setBreakDownWeek(today, ref);
              }
              ref.watch(todayOnlyProvider.notifier).state =
                  !ref.watch(todayOnlyProvider.notifier).state;
            },
          ),
        )
      ],
    ));
  }

  void setBreakDownToday(DateTime today, WidgetRef ref) {
    final filteredData = data.where((element) {
      final elementDate = DateTime.fromMillisecondsSinceEpoch(element.date);
      return elementDate.day == today.day &&
          elementDate.month == today.month &&
          elementDate.year == today.year;
    }).toList();
    ref.watch(pointsProvider.notifier).state = filteredData.fold<double>(
        0, (previousValue, element) => previousValue + element.points);
    ref.watch(caloriesProvider.notifier).state = filteredData.fold<double>(
        0, (previousValue, element) => previousValue + element.energy);
    ref.watch(carbsProvider.notifier).state = filteredData.fold<double>(
        0, (previousValue, element) => previousValue + element.carbs);
    ref.watch(proteinProvider.notifier).state = filteredData.fold<double>(
        0, (previousValue, element) => previousValue + element.protein);
    ref.watch(fatProvider.notifier).state = filteredData.fold<double>(
        0, (previousValue, element) => previousValue + element.fat);
  }

  void setBreakDownWeek(DateTime today, WidgetRef ref) {
    final past7Days = today.subtract(const Duration(days: 6));
    final filteredData = data.where((element) {
      final elementDate = DateTime.fromMillisecondsSinceEpoch(element.date);
      return elementDate.isAfter(past7Days);
    }).toList();
    ref.watch(pointsProvider.notifier).state = filteredData.fold<double>(
        0, (previousValue, element) => previousValue + element.points);
    ref.watch(caloriesProvider.notifier).state = filteredData.fold<double>(
        0, (previousValue, element) => previousValue + element.energy);
    ref.watch(carbsProvider.notifier).state = filteredData.fold<double>(
        0, (previousValue, element) => previousValue + element.carbs);
    ref.watch(proteinProvider.notifier).state = filteredData.fold<double>(
        0, (previousValue, element) => previousValue + element.protein);
    ref.watch(fatProvider.notifier).state = filteredData.fold<double>(
        0, (previousValue, element) => previousValue + element.fat);
  }
}
