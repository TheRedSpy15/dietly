import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nafp/log.dart';
import 'package:nafp/models/historydata.dart';
import 'package:nafp/models/pantryItem.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

import '../../providers/providers.dart';
import '../meals/meals.dart';

final massMeasurementProvider = StateProvider<String>((ref) => 'g');

final massNumberProvider = StateProvider<double>((ref) => 0.0);
// height cm, weight lbs, age years
int calcAllowancePlus(
    double weight, double height, int age, int activityPoints, bool isFemale) {
  // activity levels:
  // 0, 2, 4, 6

  // additonal points for age ranges:
  // 17-26 = 4
  // 27-37 = 3
  // 38-47 = 2
  // 48-57 = 1
  // 58+ = 0

  // additonal points for gender:
  // male = 8
  // female = 2

  int heightPoints, weightPoints, genderPoints, agePoints = 0;

  // height points
  if (height < 155) {
    heightPoints = 0;
  } else if (height < 178) {
    heightPoints = 1;
  } else {
    heightPoints = 2;
  }

  // weight points
  weightPoints = (weight / 10).round();

  // gender points
  if (isFemale) {
    genderPoints = 2;
  } else {
    genderPoints = 8;
  }

  // age points
  if (age < 27) {
    agePoints = 4;
  } else if (age < 38) {
    agePoints = 3;
  } else if (age < 48) {
    agePoints = 2;
  } else if (age < 58) {
    agePoints = 1;
  } else {
    agePoints = 0;
  }

  int dailyPoints =
      heightPoints + weightPoints + genderPoints + agePoints + activityPoints;
  return dailyPoints.floor().clamp(26, 71);
}

class FoodDetails extends ConsumerWidget {
  final String imageUrl;
  final String foodName;
  final double calories;
  final double carbs;
  final double fat;
  final double protein;
  final double points;
  final double sugar;
  final double salt;
  final double fiber;
  final String servings;

  const FoodDetails({
    super.key,
    this.imageUrl = '',
    this.foodName = '',
    this.calories = 0.0,
    this.carbs = 0.0,
    this.fat = 0.0,
    this.protein = 0.0,
    this.points = 0.0,
    this.sugar = 0.0,
    this.salt = 0.0,
    this.fiber = 0.0,
    this.servings = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (imageUrl.isNotEmpty)
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.transparent,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image),
                    ),
                  ),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue,
                  child: Text('${points.toInt()}',
                      style: const TextStyle(fontSize: 24.0)),
                )
              ],
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodName,
                    style: const TextStyle(
                        fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Serving: $servings',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Calories: $calories',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    'Carbs: $carbs',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    'Fat: $fat',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    'Protein: $protein',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    'Sugar: $sugar',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    'Salt: $salt',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    'Fiber: $fiber',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedButton(
                      style: ButtonStyle(
                        // max width of button as percentage of screen width
                        fixedSize: MaterialStateProperty.all<Size>(
                          Size(
                            MediaQuery.of(context).size.width * 0.8,
                            50,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        HapticFeedback.vibrate();

                        ref.read(healthProvider).whenData(
                          (health) {
                            health.points -= points.toInt();
                            health.savePoints();
                            HistoryData.addToHistory(
                                ref.read(proteinFocusProvider),
                                carbs: carbs,
                                fat: fat,
                                protein: protein,
                                calories: calories,
                                points: points,
                                sugar: sugar,
                                fiber: fiber,
                                salt: salt);
                            ref.invalidate(healthProvider);
                          },
                        );
                      },
                      child: const Text('Use Points'),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Points extends ConsumerWidget {
  const Points({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<Product?>? product;
    bool canShow = true;

    return Scaffold(
      appBar: AppBar(title: const Text('Point Scanner')),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          logger.i("Barcode detected: ${barcodes.first.rawValue}");

          final code = barcodes.first.rawValue;
          if (code != null && code.isNotEmpty && canShow && !context.canPop()) {
            canShow = false;
            logger.i("USING NEW CODE: $code");
            product = ref.read(factProvider(code).future);

            if (context.canPop()) {
              logger.i("bottom already open");
              return;
            }

            product!.then((value) {
              if (value != null) {
                showNutritionDialog(
                    value, ref.read(proteinFocusProvider), context);
              }
              canShow = true;
              if (value != null) {
                PantryItem.addToPantry(value);
                ref.invalidate(pantryProvider);
              } else {
                logger.w("Product is null");
              }
            });
          } else {
            logger.i("Already using: $code");
          }
        },
      ),
    );
  }
}
