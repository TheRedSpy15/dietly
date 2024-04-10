import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nafp/services/openfoodapi.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

Widget foodCard(Product food, bool proteinFocus, {int quantity = 1}) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.transparent,
        child: CachedNetworkImage(
          imageUrl: food.imageFrontUrl ?? "",
          errorWidget: (context, url, error) => const Icon(Icons.image),
        ),
      ),
      title: Text(food.productName ?? 'No name'),
      subtitle: Text('${calcPoints(food, proteinFocus, null).toInt()} points'),
      trailing: Text('x$quantity'),
    ),
  );
}
