import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 1)
class Product extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double price;

  @HiveField(2)
  double purchasePrice;

  Product({
    required this.name,
    required this.price,
    this.purchasePrice = 0.0,
  });

  // إضافة Factory للتعامل الآمن مع البيانات القادمة من الـ JSON أو الخزن القديم
  factory Product.fromJson(Map<dynamic, dynamic> json) {
    return Product(
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}