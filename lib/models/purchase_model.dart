import 'package:hive/hive.dart';

part 'purchase_model.g.dart';

@HiveType(typeId: 6) // تأكد من عدم تكرار typeId مع النماذج الأخرى
class SupplierPurchase extends HiveObject {
  @HiveField(0)
  String supplierName;

  @HiveField(1)
  String phoneNumber;

  @HiveField(2)
  String itemName;

  @HiveField(3)
  double quantity;

  @HiveField(4)
  double purchasePrice;

  @HiveField(5)
  double paidAmount;

  @HiveField(6)
  String note;

  @HiveField(7)
  DateTime date;

  SupplierPurchase({
    required this.supplierName,
    required this.phoneNumber,
    required this.itemName,
    required this.quantity,
    required this.purchasePrice,
    required this.paidAmount,
    required this.note,
    required this.date,
  });

  double get totalAmount => quantity * purchasePrice;
  double get remainingBalance => totalAmount - paidAmount;
}