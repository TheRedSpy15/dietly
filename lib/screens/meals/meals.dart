import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafp/log.dart';
import 'package:nafp/services/generation.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shimmer/shimmer.dart';

import '../../placeholders.dart';
import '../../providers/providers.dart';
import '../../services/openfoodapi.dart';
import '../points/points.dart';
import 'healthDataForm.dart';

void showNutritionDialog(
    Product product, bool proteinFocus, BuildContext context) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            SizedBox(
              child: Center(
                child: FoodDetails(
                  imageUrl: product.imageFrontUrl ?? '',
                  foodName: product.productName ?? '',
                  calories: product.nutriments
                          ?.getValue(Nutrient.energyKCal, PerSize.serving) ??
                      0.0,
                  carbs: product.nutriments
                          ?.getValue(Nutrient.carbohydrates, PerSize.serving) ??
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
      });
}

class FoodCardActiveConsumer extends ConsumerWidget {
  final Product food;
  const FoodCardActiveConsumer({super.key, required this.food});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var proteinFocus = ref.watch(proteinFocusProvider);

    return GestureDetector(
      onTap: () {
        showNutritionDialog(food, ref.read(proteinFocusProvider), context);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: CachedNetworkImage(
              imageUrl: food.imageFrontUrl ?? "",
              errorWidget: (context, url, error) => const Icon(Icons.image),
            ),
          ),
          title: Text(food.productName ?? 'No name'),
          subtitle:
              Text('${calcPoints(food, proteinFocus, null).toInt()} points'),
        ),
      ),
    );
  }
}

class FoodSearchDelegate extends SearchDelegate {
  bool isDarkMode = true;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return productSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return productSearchResults();
  }

  ListView productSearchResults() {
    ProductSearchQueryConfiguration configuration =
        ProductSearchQueryConfiguration(
            parametersList: <Parameter>[
              SearchTerms(terms: [query]),
              const SortBy(option: SortOption.POPULARITY),
              const PageSize(size: 5),
            ],
            version: ProductQueryVersion.v3,
            fields: [
              ProductField.NUTRIMENTS,
              ProductField.IMAGE_FRONT_URL,
              ProductField.NAME,
              ProductField.CATEGORIES_TAGS,
              ProductField.SERVING_QUANTITY,
              ProductField.SERVING_SIZE,
              ProductField.BARCODE,
            ]);

    var offResult = OpenFoodAPIClient.searchProducts(null, configuration);

    return ListView(children: [
      if (query.trim().isNotEmpty) GeminiFoodCard(food: query),
      FutureBuilder(
        future: offResult,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: snapshot.data?.products
                      ?.map((e) => FoodCardActiveConsumer(food: e))
                      .toList() ??
                  [],
            );
          } else if (snapshot.hasError) {
            logger.w("Error: ${snapshot.error.toString()}");
            return const ListTile(
                title: Text("Food Database failed to generate results"));
          } else {
            return Column(
              children: [
                Shimmer.fromColors(
                    baseColor: Colors.black12,
                    highlightColor: Colors.white,
                    enabled: true,
                    child: const SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(height: 16.0),
                          ContentPlaceholder(
                            lineType: ContentLineType.threeLines,
                          ),
                          SizedBox(height: 16.0),
                          SizedBox(height: 16.0),
                          ContentPlaceholder(
                            lineType: ContentLineType.twoLines,
                          ),
                          SizedBox(height: 16.0),
                          SizedBox(height: 16.0),
                          ContentPlaceholder(
                            lineType: ContentLineType.twoLines,
                          ),
                        ],
                      ),
                    ))
              ],
            );
          }
        },
      )
    ]);
  }
}

class Meals extends ConsumerWidget {
  const Meals({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthData = ref.watch(healthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meals'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: FoodSearchDelegate());
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: Center(
        child: healthData.when(
          data: (data) {
            if (data.weight == 0) {
              return HealthDataForm();
            }

            return ListView(
              scrollDirection: Axis.vertical,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text("Daily Points",
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                ),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blueGrey,
                  child: Text(
                      '${data.points.toInt()} / ${data.dailyAllowance.toInt()}',
                      style: const TextStyle(fontSize: 24.0)),
                ),
                ...ref.watch(pantryProvider).when(
                    data: (pantry) {
                      return pantry
                          .map((e) => FoodCardActiveConsumer(food: e.item))
                          .toList()
                          .reversed;
                    },
                    loading: () => const [CircularProgressIndicator()],
                    error: (o, e) {
                      logger.e("Error: $o");
                      logger.e("Error: $e");
                      return const [Text('Failed loading data :(')];
                    }),
              ],
            );
          },
          error: (o, e) {
            logger.e("Error: $o");
            logger.e("Error: $e");
            return const Text('Failed loading data :(');
          },
          loading: () => const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
