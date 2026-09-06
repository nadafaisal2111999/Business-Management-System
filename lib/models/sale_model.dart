import 'package:hive/hive.dart';

part 'sale_model.g.dart';

@HiveType(typeId: 2)
class SaleItem extends HiveObject {
  @HiveField(0)
  final String customerName; // لربط العنصر بالعميل المسؤول

  @HiveField(1)
  final String productName; // اسم المنتج

  @HiveField(2)
  final int quantity; // الكمية

  @HiveField(3)
  final double totalPrice; // إجمالي السعر

  @HiveField(4)
  final DateTime date; // تاريخ البيع

  SaleItem({
    required this.customerName,
    required this.productName,
    required this.quantity,
    required this.totalPrice,
    required this.date,
  });
}