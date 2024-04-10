import 'package:nafp/log.dart';
import 'package:nafp/services/database.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:sembast/sembast.dart';

class PantryItem {
  Product item;
  DateTime added = DateTime.now();

  PantryItem({required this.item});

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    if (json['item'] == null) {
      throw ArgumentError("Item is required");
    }

    return PantryItem(
      item: Product.fromJson(json['item']),
    );
  }

  Map<String, dynamic> toJson() => {
        'item': item.toJson(),
      };

  static void addToPantry(Product product) async {
    final item = PantryItem(item: product);
    final key = await addData(item.toJson(), "pantry");
    logger.i("Added pantry item: $key");
  }

  static Future<List<PantryItem>> loadPantry() async {
    List<PantryItem> pantry = [];
    try {
      final data = await readAllData("pantry", SortOrder("added"), 10);
      for (var item in data) {
        if (item.value['item'] == null) {
          continue;
        }

        pantry.add(PantryItem.fromJson(item.value));
      }
      return pantry;
    } catch (e) {
      logger.e("Error loading pantry data: $e");
      return [];
    }
  }
}
