import 'package:hive/hive.dart';

// هذا السطر مهم جداً عشان الـ build_runner يعرف ينشئ ملف الـ adapter التلقائي
part 'customer_model.g.dart'; //عشان استتخدمنا ال hive بدون قاعدة بيانات خارجية، لازم نضيف هذا السطر عشان ينشئ ملف الـ adapter التلقائي

@HiveType(typeId: 0) // رقم مميز وخاص بهذا المودل داخل الـ Hive
class Customer extends HiveObject {
  @HiveField(0) // رقم الحقل داخل الـ Hive
  final String name;

  @HiveField(1)
  final String phone;

  @HiveField(2)
  final String city;

  Customer({
    required this.name,
    required this.phone,
    required this.city,
  });
}