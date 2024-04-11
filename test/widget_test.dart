// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:nafp/screens/points/points.dart';
import 'package:nafp/services/openfoodapi.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

void main() {
  test('Allowance male', () {
    expect(calcAllowancePlus(210, 188, 21, 4, false), 39);
  });

  test('Allowance female', () {
    expect(calcAllowancePlus(230, 170.18, 51, 0, true), 27);
  });

  test('Food value 1', () {
    Product product = Product();
    product.nutriments = Nutriments.empty();
    product.nutriments!.setValue(Nutrient.energyKCal, PerSize.serving, 100);
    product.nutriments!.setValue(Nutrient.proteins, PerSize.serving, 10);
    product.nutriments!.setValue(Nutrient.fat, PerSize.serving, 5);
    product.nutriments!.setValue(Nutrient.carbohydrates, PerSize.serving, 20);
    product.nutriments!.setValue(Nutrient.fiber, PerSize.serving, 5);
    expect(calcPoints(product, true, null), 4.0);
  });
}
