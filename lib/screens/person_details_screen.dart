import 'package:flutter/material.dart';
import '../models/category_model.dart';

class PersonDetailsScreen extends StatefulWidget {
  final String personName;
  final List<CategoryModel> personCategories;
  final Color themeColor;

  const PersonDetailsScreen({
    super.key,
    required this.personName,
    required this.personCategories,
    required this.themeColor,
  });

  @override
  State<PersonDetailsScreen> createState() => _PersonDetailsScreenState();
}

class _PersonDetailsScreenState extends State<PersonDetailsScreen> {
  // دالة لتصفية السجلات بحيث لا يظهر إلا صف الشخص المطلوب
  List<Map<String, String>> _getFilteredRecords(CategoryModel category) {
    return category.records.where((record) {
      bool isTargetPerson = false;
      record.forEach((key, value) {
        String k = key.toLowerCase();
        String val = value.trim();
        if ((k.contains('مورد') || k.contains('عميل') || k.contains('اسم') || k.contains('العميل') || k.contains('المورد')) &&
            val.toLowerCase() == widget.personName.toLowerCase()) {
          isTargetPerson = true;
        }
      });
      return isTargetPerson;
    }).toList();
  }

  // حساب إجمالي الديون الخاصة بهذا الشخص فقط من السجلات المفلترة
  double _calculatePersonTotalDebt() {
    double total = 0.0;
    for (var category in widget.personCategories) {
      List<Map<String, String>> filteredRecords = _getFilteredRecords(category);
      for (var record in filteredRecords) {
        record.forEach((key, value) {
          String k = key.toLowerCase();
          if (k.contains('متبقي') || k.contains('باقي') || k.contains('remaining')) {
            total += double.tryParse(value.trim()) ?? 0.0;
          }
        });
      }
    }
    return total;
  }

  // دالة خصم أو سداد جزء من الدين (أو كله لتصفير السجل وإخفائه)
  void _showPaymentDialog(BuildContext context) {
    final TextEditingController paymentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('سداد / خصم مبلغ'),
          content: TextField(
            controller: paymentController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'أدخل المبلغ المراد خصمه أو سداده',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: widget.themeColor, foregroundColor: Colors.white),
              onPressed: () {
                double paymentAmount = double.tryParse(paymentController.text.trim()) ?? 0.0;
                if (paymentAmount > 0) {
                  setState(() {
                    _deductDebtFromRecords(paymentAmount);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم خصم الدفعة بنجاح وتحديث الحساب 📊')),
                  );
                }
              },
              child: const Text('تأكيد السداد'),
            ),
          ],
        );
      },
    );
  }

  // منطق خصم المبلغ من سجلات الشخص وحذف السجلات التي تصبح صفر أو أقل
  void _deductDebtFromRecords(double amountToPay) {
    for (var category in widget.personCategories) {
      bool categoryChanged = false;

      // نمر على نسخة من السجلات الأصلية للتح تعديلها
      for (int i = category.records.length - 1; i >= 0; i--) {
        var record = category.records[i];

        // التأكد هل هذا السجل يخص الشخص الحالي؟
        bool isTargetPerson = false;
        record.forEach((key, value) {
          String k = key.toLowerCase();
          String val = value.trim();
          if ((k.contains('مورد') || k.contains('عميل') || k.contains('اسم') || k.contains('العميل') || k.contains('المورد')) &&
              val.toLowerCase() == widget.personName.toLowerCase()) {
            isTargetPerson = true;
          }
        });

        if (isTargetPerson) {
          // نبحث عن حقل "المتبقي" أو "باقي" لخصم المبلغ منه
          String? remainingKey;
          double currentRemaining = 0.0;

          record.forEach((key, value) {
            String k = key.toLowerCase();
            if (k.contains('متبقي') || k.contains('باقي') || k.contains('remaining')) {
              remainingKey = key;
              currentRemaining = double.tryParse(value.trim()) ?? 0.0;
            }
          });

          if (remainingKey != null) {
            double newRemaining = currentRemaining - amountToPay;

            if (newRemaining <= 0) {
              // إذا سدد كل الدين أو أكثر، يتم حذف هذا السجل نهائياً (ليختفي الاسم/السجل)
              category.records.removeAt(i);
              categoryChanged = true;
            } else {
              // إذا سدد جزء وبقي جزء، نقوم بتحديث قيمة المتبقي في السجل
              record[remainingKey!] = newRemaining.toStringAsFixed(2);
              categoryChanged = true;
            }

            // نكتفي بخصم المبلغ من أول سجل نتاجه أو نوزعه (حسب الرغبة، هنا نخصمه من السجل الرئيسي النشط)
            amountToPay = 0; // تم الاستهلاك
            break;
          }
        }
      }

      if (categoryChanged) {
        category.save(); // حفظ التغييرات في Hive
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double personTotalDebt = _calculatePersonTotalDebt();

    return Scaffold(
      appBar: AppBar(
        title: Text('حساب: ${widget.personName}'),
        centerTitle: true,
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // كارت إجمالي مديونية الشخص مع زر السداد المدمج
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.themeColor, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إجمالي المبالغ المتبقية عليه/له:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${personTotalDebt.toStringAsFixed(2)} جنيه',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: widget.themeColor),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showPaymentDialog(context),
                    icon: const Icon(Icons.payment, size: 18),
                    label: const Text('سداد دفعة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'فواتير وسجلات هذا الشخص فقط:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: widget.personCategories.isEmpty || personTotalDebt <= 0
                  ? const Center(
                child: Text(
                  'لا توجد سجلات مسجلة أو تم سداد بالكامل.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: widget.personCategories.length,
                itemBuilder: (context, index) {
                  final category = widget.personCategories[index];
                  final List<String> attributes = category.selectedAttributes;
                  final List<Map<String, String>> filteredRecords = _getFilteredRecords(category);

                  if (filteredRecords.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اسم الجدول: ${category.tableName}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: widget.themeColor,
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 4),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Table(
                              defaultColumnWidth: const FixedColumnWidth(110),
                              columnWidths: {
                                0: const FixedColumnWidth(40),
                                for (int i = 1; i <= attributes.length; i++)
                                  i: const FixedColumnWidth(110),
                              },
                              border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(color: Colors.grey.shade200),
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text('م', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ),
                                    ...attributes.map((attr) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text(
                                          attr,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                                ...List.generate(filteredRecords.length, (rIndex) {
                                  final record = filteredRecords[rIndex];
                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text('${rIndex + 1}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                                      ),
                                      ...attributes.map((attr) {
                                        final String? val = record[attr];
                                        return Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            val?.isNotEmpty == true ? val! : '-',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        );
                                      }),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}