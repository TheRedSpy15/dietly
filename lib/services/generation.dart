import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafp/log.dart';
import 'package:nafp/providers/providers.dart';
import 'package:nafp/screens/points/points.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

import 'openfoodapi.dart';

// riverpod future provider for openaiProductRequest
final geminiProductProvider =
    FutureProvider.family<Product, String>((ref, food) async {
  return await geminiProductRequest(food);
});

Future<Product> geminiProductRequest(String food) async {
  final gemini = Gemini.instance;

  try {
    final resp = await gemini.text(
        "create a json for a generic \"$food\" serving with structure (return just the number where the data type is int): '{\"calories\": int, \"carbs\": int,\"fat\": int,\"protein\": int,\"sugar\": int,\"fiber\": int,\"serving_size\": \"number char\"}");

    logger.i('Gemini response: ${resp?.content?.parts?[0].text}');
    // parse response
    final foodJson = jsonDecode(resp?.content?.parts?[0].text ?? '');

    // create product from json
    final product = Product();
    product.nutriments = Nutriments.empty();
    product.productName = "Generic $food";
    product.nutriments!.setValue(
        Nutrient.energyKCal, PerSize.serving, foodJson['calories'].toDouble());
    product.nutriments!.setValue(
        Nutrient.proteins, PerSize.serving, foodJson['protein'].toDouble());
    product.nutriments!
        .setValue(Nutrient.fat, PerSize.serving, foodJson['fat'].toDouble());
    product.nutriments!.setValue(
        Nutrient.carbohydrates, PerSize.serving, foodJson['carbs'].toDouble());
    product.nutriments!.setValue(
        Nutrient.fiber, PerSize.serving, foodJson['fiber'].toDouble());
    product.servingSize = foodJson['serving_size'];

    return product;
  } catch (e) {
    logger.e('Error creating AI food: $e');
    return Product();
  }
}

class GeminiFoodCard extends StatelessWidget {
  final String food;
  const GeminiFoodCard({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return Wrap(
                children: [
                  SizedBox(
                    child: Center(child: GeminiFoodSheetContent(food: food)),
                  )
                ],
              );
            });
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: ListTile(
          leading: const Icon(CupertinoIcons.lightbulb),
          title: Text(food),
          subtitle: const Text('Generate Nutrition Data with AI'),
        ),
      ),
    );
  }
}

class GeminiFoodSheetContent extends ConsumerWidget {
  final String food;
  const GeminiFoodSheetContent({super.key, required this.food});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var proteinFocus = ref.watch(proteinFocusProvider);

    return ref.watch(geminiProductProvider(food)).when(
          data: (product) {
            return Wrap(
              children: [
                SizedBox(
                  child: Center(
                    child: FoodDetails(
                      imageUrl: product.imageFrontUrl ?? '',
                      foodName: product.productName ?? '',
                      calories: product.nutriments?.getValue(
                              Nutrient.energyKCal, PerSize.serving) ??
                          0.0,
                      carbs: product.nutriments?.getValue(
                              Nutrient.carbohydrates, PerSize.serving) ??
                          0.0,
                      fat: product.nutriments
                              ?.getValue(Nutrient.fat, PerSize.serving) ??
                          0.0,
                      protein: product.nutriments
                              ?.getValue(Nutrient.proteins, PerSize.serving) ??
                          0.0,
                      points: calcPoints(product, proteinFocus, null),
                      sugar: product.nutriments
                              ?.getValue(Nutrient.sugars, PerSize.serving) ??
                          0.0,
                      salt: product.nutriments
                              ?.getValue(Nutrient.salt, PerSize.serving) ??
                          0.0,
                      fiber: product.nutriments
                              ?.getValue(Nutrient.fiber, PerSize.serving) ??
                          0.0,
                      servings: product.servingSize ?? '',
                    ),
                  ),
                )
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
          error: (err, stack) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Failed to initialize Gemini AI. $err'),
          ),
        );
  }
}
