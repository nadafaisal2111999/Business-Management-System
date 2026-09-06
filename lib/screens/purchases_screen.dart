import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/category_model.dart';
import '../models/supplier_model.dart';
import '../models/product_model.dart';

class PurchasesScreen extends StatefulWidget {
  final CategoryModel category;

  const PurchasesScreen({
    super.key,
    required this.category,
  });

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final Map<String, TextEditingController> _controllers = {};
  late List<Map<String, String>> _tableRecords;

  late Box<SupplierModel> _suppliersBox;
  late Box<Product> _productsBox;

  @override
  void initState() {
    super.initState();
    _tableRecords = List.from(widget.category.records);

    for (final attr in widget.category.selectedAttributes) {
      _controllers[attr] = TextEditingController();
    }

    _suppliersBox = Hive.box<SupplierModel>('suppliersBox');
    _productsBox = Hive.box<Product>('productsBox');

    // تعيين التاريخ الحالي تلقائياً إذا وجد حقل للتاريخ
    _setInitialDate();
  }

  void _setInitialDate() {
    final String today = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD
    _controllers.forEach((key, controller) {
      String k = key.toLowerCase();
      if (k.contains('تاريخ') || k.contains('date')) {
        if (controller.text.isEmpty) {
          controller.text = today;
        }
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _calculateTotals() {
    double price = 0;
    double quantity = 0;
    double paid = 0;

    _controllers.forEach((key, controller) {
      String k = key.toLowerCase();
      double val = double.tryParse(controller.text.trim()) ?? 0;

      if (k.contains('سعر') || k.contains('price') || k.contains('تكلفة')) {
        price = val;
      } else if (k.contains('كمية') || k.contains('عدد') || k.contains('quantity')) {
        quantity = val;
      } else if (k.contains('مدفوع') || k.contains('واصل') || k.contains('paid')) {
        paid = val;
      }
    });

    double total = price * (quantity == 0 ? 1 : quantity);
    double remaining = total - paid;

    _controllers.forEach((key, controller) {
      String k = key.toLowerCase();
      if (k.contains('إجمالي') || k.contains('اجمالي') || k.contains('total')) {
        if (total > 0) controller.text = total.toStringAsFixed(2);
      } else if (k.contains('متبقي') || k.contains('باقي') || k.contains('remaining')) {
        controller.text = remaining.toStringAsFixed(2);
      }
    });
  }

  void _saveDataRecord() {
    // تعيين التاريخ الحالي قبل الحفظ إن وجد الحقل
    final String today = DateTime.now().toString().split(' ')[0];
    _controllers.forEach((key, controller) {
      String k = key.toLowerCase();
      if ((k.contains('تاريخ') || k.contains('date')) && controller.text.trim().isEmpty) {
        controller.text = today;
      }
    });

    final bool hasData = _controllers.values.any(
          (controller) => controller.text.trim().isNotEmpty,
    );

    if (!hasData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('من فضلك ادخل بعض البيانات أولاً'),
        ),
      );
      return;
    }

    final Map<String, String> newRecord = {};
    _controllers.forEach((key, controller) {
      newRecord[key] = controller.text.trim();
    });

    setState(() {
      _tableRecords.add(newRecord);
      widget.category.records = List.from(_tableRecords);
      widget.category.save();

      for (final controller in _controllers.values) {
        controller.clear();
      }
      _setInitialDate(); // إعادة تعيين التاريخ للسجل القادم
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إضافة وحفظ سجل المشتريات بنجاح! 📊'),
      ),
    );
  }

  Widget _buildFieldWidget(String attr) {
    String lowerAttr = attr.toLowerCase();

    bool isProductField = lowerAttr.contains('منتج') ||
        lowerAttr.contains('صنف') ||
        lowerAttr.contains('item') ||
        lowerAttr.contains('product') ||
        lowerAttr.contains('القطعة');

    bool isSupplierField = lowerAttr.contains('مورد') ||
        lowerAttr.contains('supplier') ||
        (lowerAttr.contains('اسم') && !isProductField);

    if (isProductField) {
      return Autocomplete<Product>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<Product>.empty();
          }
          return _productsBox.values.where((Product product) {
            return product.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
          });
        },
        displayStringForOption: (Product product) => product.name,
        onSelected: (Product selection) {
          _controllers[attr]?.text = selection.name;
          _controllers.forEach((key, controller) {
            String k = key.toLowerCase();
            if (k.contains('سعر') || k.contains('price') || k.contains('تكلفة')) {
              controller.text = selection.price.toString();
            }
          });
          _calculateTotals();
          setState(() {});
        },
        fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
          if (_controllers[attr]!.text.isNotEmpty && textController.text != _controllers[attr]!.text) {
            textController.text = _controllers[attr]!.text;
          }
          return TextField(
            controller: textController,
            focusNode: focusNode,
            onChanged: (value) {
              _controllers[attr]?.text = value;
              _calculateTotals();
            },
            decoration: InputDecoration(
              labelText: attr,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          );
        },
      );
    } else if (isSupplierField) {
      return Autocomplete<SupplierModel>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<SupplierModel>.empty();
          }
          return _suppliersBox.values.where((SupplierModel supplier) {
            return supplier.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
          });
        },
        displayStringForOption: (SupplierModel supplier) => supplier.name,
        onSelected: (SupplierModel selection) {
          _controllers[attr]?.text = selection.name;
          // جلب بيانات المورد التلقائية (الهاتف والمدينة) وتعبئتها في الحقول المرتبطة
          _controllers.forEach((key, controller) {
            String k = key.toLowerCase();
            if (k.contains('هاتف') || k.contains('رقم') || k.contains('phone')) {
              controller.text = selection.phone;
            }
            if (k.contains('مدينة') || k.contains('عنوان') || k.contains('city')) {
              controller.text = selection.city;
            }
          });
          setState(() {});
        },
        fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
          if (_controllers[attr]!.text.isNotEmpty && textController.text != _controllers[attr]!.text) {
            textController.text = _controllers[attr]!.text;
          }
          return TextField(
            controller: textController,
            focusNode: focusNode,
            onChanged: (value) {
              _controllers[attr]?.text = value;
            },
            decoration: InputDecoration(
              labelText: attr,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          );
        },
      );
    }

    return TextField(
      controller: _controllers[attr],
      onChanged: (value) {
        _calculateTotals();
      },
      decoration: InputDecoration(
        labelText: attr,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> attributes = widget.category.selectedAttributes;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.tableName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'إدخال مشتريات جديدة:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 2,
                child: ListView(
                  children: attributes.map((attr) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildFieldWidget(attr),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _saveDataRecord,
                  icon: const Icon(Icons.add, color: Colors.white, size: 21),
                  label: const Text(
                    'إضافة للجدول',
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(thickness: 2),
              const Text(
                'جدول سجلات المشتريات:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 3,
                child: _tableRecords.isEmpty
                    ? const Center(
                  child: Text(
                    'لا توجد مشتريات مسجلة حتى الآن.',
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                )
                    : Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SizedBox(
                            width: constraints.maxWidth,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.topCenter,
                              child: Table(
                                defaultColumnWidth: const FixedColumnWidth(120),
                                columnWidths: {
                                  0: const FixedColumnWidth(50),
                                  for (int i = 1; i <= attributes.length; i++)
                                    i: const FixedColumnWidth(120),
                                },
                                border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(color: Colors.grey.shade200),
                                    children: [
                                      const SizedBox(
                                        width: 50,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 14),
                                          child: Text(
                                            'م',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ),
                                      ),
                                      ...attributes.map((attr) {
                                        return SizedBox(
                                          width: 120,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                                            child: Text(
                                              attr,
                                              textAlign: TextAlign.center,
                                              softWrap: true,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.4),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                  ...List.generate(_tableRecords.length, (index) {
                                    final record = _tableRecords[index];
                                    return TableRow(
                                      children: [
                                        SizedBox(
                                          width: 50,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
                                            child: Text(
                                              '${index + 1}',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 15),
                                            ),
                                          ),
                                        ),
                                        ...attributes.map((attr) {
                                          final String? value = record[attr];
                                          return SizedBox(
                                            width: 120,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                                              child: Text(
                                                value?.isNotEmpty == true ? value! : '-',
                                                textAlign: TextAlign.center,
                                                softWrap: true,
                                                style: const TextStyle(fontSize: 15, height: 1.4),
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}