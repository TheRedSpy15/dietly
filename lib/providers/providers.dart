import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafp/models/historydata.dart';
import 'package:nafp/models/pantryItem.dart';
import 'package:nafp/models/pocketbase/blogpost.dart';
import 'package:nafp/models/userhealth.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

import '../services/openfoodapi.dart';

final blogPostProvider = Provider<BlogPost>((ref) => BlogPost(
    id: '0',
    title: 'Progress',
    content: 'No progress posts yet',
    author: 'Dietly Admin',
    created: '',
    updated: ''));

final factProvider = FutureProvider.family<Product?, String>((ref, code) async {
  return getProduct(code);
});

// get feed data
final feedProvider = FutureProvider.autoDispose<List<BlogPost>>((ref) async {
  return ref.read(blogPostProvider).getBlogPosts();
});

final healthProvider = FutureProvider.autoDispose<UserHealth>((ref) async {
  return UserHealth().loadHealth();
});

final historyProvider =
    FutureProvider.autoDispose<List<HistoryData>>((ref) async {
  return HistoryData.loadHistory();
});

final hourlyWaterProvider = StateProvider<bool>((ref) => false);

final ingredientsFactProvider = FutureProvider.autoDispose
    .family<Map<Product, int>, Map<String, int>>((ref, ingredient) async {
  // get product for each ingredient as single future
  return Future.wait(ingredient.entries.map((e) => getProduct(e.key)))
      .then((products) {
    // create map of products and amounts
    final productMap =
        Map<Product?, int>.fromIterables(products, ingredient.values);
    // remove null products
    productMap.removeWhere((key, value) => key == null);
    // convert to Map<Product, int>
    return Map<Product, int>.from(productMap);
  });
});

final pantryProvider = FutureProvider<List<PantryItem>>((ref) async {
  return PantryItem.loadPantry();
});

final premiumProvider = StateProvider<bool>((ref) => false);

// settings
final proteinFocusProvider = StateProvider<bool>((ref) => false);
