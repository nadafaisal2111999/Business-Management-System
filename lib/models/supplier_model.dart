import 'package:hive/hive.dart';

part 'supplier_model.g.dart';

@HiveType(typeId: 7)
class SupplierModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String phone;

  @HiveField(2)
  final String city;

  SupplierModel({
    required this.name,
    required this.phone,
    required this.city,
  });
}