import 'dart:convert';

import 'package:nafp/log.dart';
import 'package:nafp/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserHealth {
  int id = 0;
  String user = '';
  double weight = 0;
  double height = 0;
  int points = 0;
  int dailyAllowance = 0;
  int goal = 0;
  double activity = 0;
  bool isFemale = false;
  int age = 0;

  UserHealth(
      {this.id = 0,
      this.user = '',
      this.weight = 0,
      this.height = 0,
      this.points = 0,
      this.dailyAllowance = 0,
      this.goal = 0,
      this.isFemale = false,
      this.age = 0,
      this.activity = 0}) {
    loadPoints();
  }

  factory UserHealth.fromJson(Map<String, dynamic> json) {
    return UserHealth(
      id: json['id'],
      user: json['user'],
      weight: json['weight'].toDouble(),
      height: json['height'].toDouble(),
      points: json['points'],
      dailyAllowance: json['dailyAllowance'],
      goal: json['goal'],
      isFemale: json['isFemale'],
      age: json['age'],
      activity: json['activity'].toDouble(),
    );
  }

  Future<UserHealth> loadHealth() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('health') ?? '';

    if (user.isEmpty) {
      return this;
    }

    return UserHealth.fromJson(jsonDecode(user));
  }

  Future<void> loadPoints() async {
    final today = DateTime.now().toString().substring(0, 10);
    final data = await readData(today.hashCode, "points");

    // check if points for today exist
    if (data != null) {
      points = data['points'] as int;
    } else {
      points = dailyAllowance;
    }

    logger.i("Points: $points");
  }

  Future<void> saveHealth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('health', jsonEncode(toJson()));
  }

  Future<void> savePoints() async {
    final today = DateTime.now().toString().substring(0, 10);
    await updateData({
      'date': today,
      'points': points,
    }, today.hashCode, "points");

    logger.i("Points: $points");
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user': user,
        'weight': weight,
        'height': height,
        'points': points,
        'dailyAllowance': dailyAllowance,
        'goal': goal,
        'isFemale': isFemale,
        'age': age,
        'activity': activity,
      };
}
