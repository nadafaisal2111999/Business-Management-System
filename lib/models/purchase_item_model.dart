import 'package:hive/hive.dart';

part 'purchase_item_model.g.dart';

@HiveType(typeId: 4)
class PurchaseItem extends HiveObject {
  @HiveField(0)
  final String supplierName; // لربط العنصر بالمورد المسؤول

  @HiveField(1)
  final String productName; // اسم المنتج المشتراة

  @HiveField(2)
  final int quantity; // الكمية المشتراة

  @HiveField(3)
  final double costPrice; // سعر الشراء

  PurchaseItem({
    required this.supplierName,
    required this.productName,
    required this.quantity,
    required this.costPrice,
  });
}