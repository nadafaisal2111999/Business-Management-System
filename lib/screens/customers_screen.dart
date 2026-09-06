import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer_model.dart';
import '../boxes/hive_boxes.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  // controllers لحقول الإدخال في نافذة الإضافة
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  // دالة لحفظ العميل الجديد في قاعدة بيانات Hive
  void _addCustomer() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final city = _cityController.text.trim();

    if (name.isEmpty) return; // لو الاسم فارغ لا تقم بالحفظ

    final customer = Customer(name: name, phone: phone, city: city);

    // إضافة الكائن مباشرة لصندوق العملاء
    HiveBoxes.getCustomersBox().add(customer);

    // تفريغ الحقول وإغلاق النافذة
    _nameController.clear();
    _phoneController.clear();
    _cityController.clear();

    Navigator.pop(context);
  }

  // دالة لإظهار نافذة (Dialog) إضافة عميل
  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إضافة عميل جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم العميل'),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'المدينة'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: _addCustomer,
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
        title: const Text('دفتر العملاء'),
        centerTitle: true,
      ),
      // ربط الشاشة بصندوق Hive لتحديث البيانات فوراً
      body: ValueListenableBuilder<Box<Customer>>(
        valueListenable: HiveBoxes.getCustomersBox().listenable(),
        builder: (context, box, _) {
          final customers = box.values.toList().cast<Customer>();

          if (customers.isEmpty) {
            const center = Center(child: Text('لا يوجد عملاء مضافون حالياً'));
            return center;
          }

          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(customer.name[0]), // أول حرف من اسم العميل
                  ),
                  title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('الهاتف: ${customer.phone} - المدينة: ${customer.city}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // حذف العميل مباشرة من الـ Hive
                      customer.delete();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomerDialog,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}