import 'package:hive/hive.dart';

part 'purchase_invoice_model.g.dart';
 //لفاتوره الشراء، تحتوي على اسم المورد وتاريخ الفاتورة
@HiveType(typeId: 3)
class PurchaseInvoice extends HiveObject {
  @HiveField(0)
  final String supplierName; // اسم المورد

  @HiveField(1)
  final DateTime date; // تاريخ الفاتورة

  PurchaseInvoice({
    required this.supplierName,
    required this.date,
  });
}