import 'package:openfoodfacts/openfoodfacts.dart';

class Plan {
  String name;
  Map<String, List<Product>> items;

  Plan({this.name = "plan", this.items = const {}});

  factory Plan.fromJson(Map<String, dynamic> json) {
    var itemsJson = json['items'] as Map<String, dynamic>;
    Map<String, List<Product>> items = {};
    itemsJson.forEach((key, value) {
      var foodList = value as List;
      List<Product> foods = foodList.map((i) => Product.fromJson(i)).toList();
      items[key] = foods;
    });

    return Plan(name: json['name'], items: items);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'items': Map.fromEntries(items.entries.map((e) =>
            MapEntry(e.key, e.value.map((food) => food.toJson()).toList()))),
      };

  static void addToPlans(Plan plan) {}
}
