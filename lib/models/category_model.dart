import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 5)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String tableName; // اسم الجدول أو التصنيف

  @HiveField(1)
  final List<String> selectedAttributes; // الحقول المختارة

  @HiveField(2)
  List<Map<String, String>> records; // قائمة السجلات المدخلة لتبقى محفوظة محلياً

  CategoryModel({
    required this.tableName,
    required this.selectedAttributes,
    List<Map<String, String>>? records,
  }) : records = records ?? [];
}