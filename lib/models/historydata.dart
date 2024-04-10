import 'package:intl/intl.dart';
import 'package:nafp/log.dart';
import 'package:nafp/services/database.dart';
import 'package:sembast/sembast.dart';

class HistoryData {
  final int date;
  final double points;
  final double sugar;
  final double fat;
  final double energy;
  final double protein;
  final double salt;
  final double carbs;
  final double fiber;

  HistoryData(
      {required this.date,
      required this.points,
      required this.sugar,
      required this.fat,
      required this.energy,
      required this.protein,
      required this.salt,
      required this.carbs,
      required this.fiber});

  factory HistoryData.fromJson(Map<String, dynamic> json) {
    return HistoryData(
      date: json['date'],
      points: json['points'],
      sugar: json['sugar'],
      fat: json['fat'],
      energy: json['energy'],
      protein: json['protein'],
      salt: json['salt'],
      carbs: json['carbs'],
      fiber: json['fiber'],
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'points': points,
        'sugar': sugar,
        'fat': fat,
        'energy': energy,
        'protein': protein,
        'salt': salt,
        'carbs': carbs,
        'fiber': fiber,
      };

  static Future<void> addToHistory(bool proteinFocus,
      {required double points,
      required double sugar,
      required double fat,
      required double calories,
      required double protein,
      required double salt,
      required double carbs,
      required double fiber}) async {
    final date = DateTime.now().millisecondsSinceEpoch;

    final historyData = HistoryData(
        date: date,
        points: points,
        sugar: sugar,
        fat: fat,
        energy: calories,
        protein: protein,
        salt: salt,
        carbs: carbs,
        fiber: fiber);

    // save as json
    addData(historyData.toJson(), "history");
  }

  static List<double> getPointsFromPastWeek(List<HistoryData> history) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    final todayIndex = now.weekday % 7; // Ensure index is between 0 and 6
    final days = [
      'Sun',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
    ];
    final reorderedDays = [
      ...days.sublist(todayIndex),
      ...days.sublist(0, todayIndex)
    ].reversed.toList();
    final pointsFromPastWeek =
        List.generate(7, (index) => 0.0, growable: false);

    for (var element in history) {
      final date = DateTime.fromMillisecondsSinceEpoch(element.date);
      if (date.isAfter(weekAgo)) {
        // line up the days
        final dayIndex = reorderedDays.indexOf(DateFormat('EEE').format(date));
        pointsFromPastWeek[dayIndex] += element.points;
      }
    }

    // if there are less than 7 values, add 0s to the list
    while (pointsFromPastWeek.length < 7) {
      pointsFromPastWeek.add(0);
    }

    return pointsFromPastWeek;
  }

  static Future<List<HistoryData>> loadHistory() async {
    final List<HistoryData> history = [];
    final data = await readAllData("history", SortOrder("date"), 100);

    // load history from hive
    for (var element in data) {
      final historyData = HistoryData.fromJson(element.value);
      history.add(historyData);
    }

    // if history is empty, add a default value
    if (history.isEmpty) {
      final historyData = HistoryData(
          date: DateTime.now().millisecondsSinceEpoch,
          points: 0,
          sugar: 0,
          fat: 0,
          energy: 0,
          protein: 0,
          salt: 0,
          carbs: 0,
          fiber: 0);
      history.add(historyData);
    }

    logger.i("History: ${history.length}");
    return history;
  }
}
