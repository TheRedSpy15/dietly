import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafp/models/plan.dart';
import 'package:nafp/screens/meals/meals.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class PlanPage extends ConsumerWidget {
  final Plan plan;

  const PlanPage({super.key, required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plan.name),
      ),
      body: ListView.builder(
        itemCount: plan.items.length,
        itemBuilder: (context, index) {
          String day = plan.items.keys.elementAt(index);
          List<Product> foods = plan.items.values.elementAt(index);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  day,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              for (var food in foods) FoodCardActiveConsumer(food: food),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
