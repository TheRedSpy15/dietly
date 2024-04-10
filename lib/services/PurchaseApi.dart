import 'package:glassfy_flutter/glassfy_flutter.dart';
import 'package:glassfy_flutter/models.dart';
import 'package:nafp/log.dart';

class PurchaseApi {
  static const _apiKey = '821feb96c6024f2b9db92964b6726cda';

  static Future<List<GlassfyOffering>> fetchOffers() async {
    try {
      final offerings = await Glassfy.offerings();
      return offerings.all ?? [];
    } catch (e) {
      logger.w("Glassfy failed to fetch offers: $e");
      return [];
    }
  }

  static Future<void> init() async {
    try {
      await Glassfy.initialize(_apiKey, watcherMode: false);
      logger.i("Glassfy initialized");
    } catch (e) {
      logger.w("Glassfy failed to initialize: $e");
    }
  }
}
