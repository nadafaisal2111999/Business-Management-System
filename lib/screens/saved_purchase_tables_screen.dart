import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';
import 'purchases_screen.dart';

class SavedPurchaseTablesScreen extends StatefulWidget {
  const SavedPurchaseTablesScreen({super.key});

  @override
  State<SavedPurchaseTablesScreen> createState() => _SavedPurchaseTablesScreenState();
}

class _SavedPurchaseTablesScreenState extends State<SavedPurchaseTablesScreen> {
  late Box<CategoryModel> _categoriesBox;

  @override
  void initState() {
    super.initState();
    _categoriesBox = Hive.box<CategoryModel>('purchaseCategoriesBox');
  }

  void _showAddTableDialog() {
    final TextEditingController nameController = TextEditingController();

    // الأعمدة الشاملة الجديدة للمشتريات
    final List<String> defaultAttributes = [
      'التاريخ',
      'المورد',
      'الهاتف',
      'المدينة',
      'المنتج',
      'الكمية',
      'السعر',
      'الإجمالي',
      'المدفوع',
      'المتبقي'
    ];
    final List<String> selectedAttributes = List.from(defaultAttributes);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إضافة جدول مشتريات جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم جدول المشتريات (مثلاً: مشتريات الشهر)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                const Text('الأعمدة الافتراضية للمشتريات:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 6,
                  children: selectedAttributes.map((attr) => Chip(label: Text(attr))).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700], foregroundColor: Colors.white),
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;

                final newCategory = CategoryModel(
                  tableName: nameController.text.trim(),
                  selectedAttributes: selectedAttributes,
                  records: [],
                );

                _categoriesBox.add(newCategory);
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جداول المشتريات'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddTableDialog,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _categoriesBox.listenable(),
        builder: (context, Box<CategoryModel> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('لا توجد جداول مشتريات محفوظة حالياً.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _showAddTableDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('إنشاء جدول مشتريات جديد'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700], foregroundColor: Colors.white),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final category = box.getAt(index)!;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.shopping_bag, color: Colors.red),
                  title: Text(category.tableName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('عدد السجلات: ${category.records.length}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () {
                      box.deleteAt(index);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PurchasesScreen(category: category),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTableDialog,
        backgroundColor: Colors.red[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}