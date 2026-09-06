import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';
import 'dynamic_data_entry_screen.dart';

class SavedTablesScreen extends StatelessWidget {
  const SavedTablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<CategoryModel>('categoriesBox');

    return Scaffold(
      appBar: AppBar(
        title: const Text('جداولك المخصصة المحفوظة'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<CategoryModel> categoriesBox, _) {
          if (categoriesBox.isEmpty) {
            return const Center(
              child: Text(
                'مفيش جداول مضافة حتى الآن!\nاضغط على إنشاء جدول جديد لبدء التصميم.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: categoriesBox.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final category = categoriesBox.getAt(index);
              if (category == null) return const SizedBox.shrink();

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.table_chart, color: Colors.white),
                  ),
                  title: Text(
                    category.tableName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'الحقول: ${category.selectedAttributes.join(', ')}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DynamicDataEntryScreen(category: category),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}