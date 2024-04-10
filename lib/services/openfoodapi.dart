import 'package:nafp/constants.dart';
import 'package:nafp/log.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

double calcPoints(Product product, bool proteinFocus, String? offTag) {
  final calories = product.nutriments?.getValue(
      Nutrient.energyKCal,
      offTag != null
          ? PerSize.fromOffTag(offTag) ?? PerSize.serving
          : PerSize.serving);
  final protein = product.nutriments?.getValue(
      Nutrient.proteins,
      offTag != null
          ? PerSize.fromOffTag(offTag) ?? PerSize.serving
          : PerSize.serving);
  final fat = product.nutriments?.getValue(
      Nutrient.fat,
      offTag != null
          ? PerSize.fromOffTag(offTag) ?? PerSize.serving
          : PerSize.serving);
  final carbs = product.nutriments?.getValue(
      Nutrient.carbohydrates,
      offTag != null
          ? PerSize.fromOffTag(offTag) ?? PerSize.serving
          : PerSize.serving);
  final fiber = product.nutriments?.getValue(
      Nutrient.fiber,
      offTag != null
          ? PerSize.fromOffTag(offTag) ?? PerSize.serving
          : PerSize.serving);
  double points = 0;

  // if is fruit or veggie points = 0
  if (product.categoriesTags != null) {
    if (product.categoriesTags!.contains("en:fruits")) {
      return 0;
    }
  }

  try {
    if (proteinFocus) {
      points = (protein! / 20) + (fat! / 4) + (carbs! / 9) - (fiber! / 35);
    } else {
      points = (protein! / 11) + (fat! / 4) + (carbs! / 9) - (fiber! / 35);
    }
  } catch (e) {
    try {
      points = (calories! / 50) + (fat! / 12) - (fiber! / 5);
    } catch (e) {
      points = 0;
    }
  }

  if (points < 0) {
    points = 0;
  }

  return points.roundToDouble();
}

bool checkIfAllNutrimentsAreNull(Product product) {
  if (product.nutriments == null) {
    return true;
  }
  if (product.nutriments!.getValue(Nutrient.energyKCal, PerSize.serving) ==
          null &&
      product.nutriments!.getValue(Nutrient.energyKJ, PerSize.serving) ==
          null &&
      product.nutriments!.getValue(Nutrient.proteins, PerSize.serving) ==
          null &&
      product.nutriments!.getValue(Nutrient.fat, PerSize.serving) == null &&
      product.nutriments!.getValue(Nutrient.carbohydrates, PerSize.serving) ==
          null &&
      product.nutriments!.getValue(Nutrient.sugars, PerSize.serving) == null &&
      product.nutriments!.getValue(Nutrient.fiber, PerSize.serving) == null) {
    return true;
  }
  return false;
}

Future<Product?> getProduct(String barcode) async {
  if (barcode.isEmpty) {
    logger.e('No barcode provided');
    throw Exception('No barcode provided');
  }
  logger.i('Getting product for barcode $barcode');

  final ProductQueryConfiguration configuration = ProductQueryConfiguration(
    barcode,
    language: OpenFoodFactsLanguage.ENGLISH,
    fields: [
      ProductField.NUTRIMENTS,
      ProductField.NUTRITION_DATA,
      ProductField.IMAGE_FRONT_URL,
      ProductField.NAME,
      ProductField.CATEGORIES_TAGS,
      ProductField.SERVING_QUANTITY,
      ProductField.SERVING_SIZE,
      ProductField.BARCODE,
    ],
    version: ProductQueryVersion.v3,
  );
  final ProductResultV3 result =
      await OpenFoodAPIClient.getProductV3(configuration);

  if (result.product != null) {
    logger.i('Got product for barcode ${result.toJson()}');

    if (checkIfAllNutrimentsAreNull(result.product!)) {
      logger.e('No nutriments for barcode $barcode');
      try {
        pb
            .collection('offRequests')
            .create(body: {'code': barcode, 'user': pb.authStore.model.id});
      } catch (e) {
        logger.e('Failed to create offRequest for barcode $barcode');
        logger.e(e);
      }
    } else {
      logger.i('Got nutriments for barcode $barcode');
      logger.i(result.product!.nutriments!.toJson());
    }

    return result.product;
  } else {
    logger.e('Failed to get product for barcode $barcode');
    logger.e(result.toJson());
    throw Exception(result.toJson());
  }
}
