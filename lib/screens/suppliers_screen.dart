import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/supplier_model.dart';
import '../boxes/hive_boxes.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  void _addSupplier() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final city = _cityController.text.trim();

    if (name.isEmpty) return;

    final supplier = SupplierModel(name: name, phone: phone, city: city);

    // افتراضي أنك ستعرفين الصندوق الخاص بالموردين في hive_boxes
    Hive.box<SupplierModel>('suppliersBox').add(supplier);

    _nameController.clear();
    _phoneController.clear();
    _cityController.clear();

    Navigator.pop(context);
  }

  void _showAddSupplierDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إضافة مورد جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم المورد'),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'المدينة / العنوان'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: _addSupplier,
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
        title: const Text('دفتر الموردين'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<Box<SupplierModel>>(
        valueListenable: Hive.box<SupplierModel>('suppliersBox').listenable(),
        builder: (context, box, _) {
          final suppliers = box.values.toList().cast<SupplierModel>();

          if (suppliers.isEmpty) {
            return const Center(child: Text('لا يوجد موردون مضافون حالياً'));
          }

          return ListView.builder(
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(supplier.name.isNotEmpty ? supplier.name[0] : ''),
                  ),
                  title: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('الهاتف: ${supplier.phone} - المدينة: ${supplier.city}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      supplier.delete();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSupplierDialog,
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }
}