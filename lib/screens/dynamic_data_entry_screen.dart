import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/category_model.dart';
import '../models/customer_model.dart';
import '../models/product_model.dart';

class DynamicDataEntryScreen extends StatefulWidget {
  final CategoryModel category;

  const DynamicDataEntryScreen({
    super.key,
    required this.category,
  });

  @override
  State<DynamicDataEntryScreen> createState() =>
      _DynamicDataEntryScreenState();
}

class _DynamicDataEntryScreenState
    extends State<DynamicDataEntryScreen> {
  final Map<String, TextEditingController> _controllers = {};

  late List<Map<String, String>> _tableRecords;

  late Box<Customer> _customersBox;
  late Box<Product> _productsBox;

  @override
  void initState() {
    super.initState();

    // استرجاع البيانات المحفوظة
    _tableRecords = List.from(widget.category.records);

    // إنشاء Controllers لكل الحقول (باستثناء حقول التاريخ والوقت التلقائية لكي لا تظهر كحقول إدخال يدوية)
    for (final attr in widget.category.selectedAttributes) {
      final String k = attr.toLowerCase();
      if (!k.contains('تاريخ') && !k.contains('date') &&
          !k.contains('وقت') && !k.contains('time')) {
        _controllers[attr] = TextEditingController();
      }
    }

    // فتح صناديق Hive
    _customersBox = Hive.box<Customer>('customersBox');
    _productsBox = Hive.box<Product>('productsBox');
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  // =========================================================
  // الحسابات التلقائية (مع فصل سعر البيع عن الشراء وحساب المكسب)
  // =========================================================
  void _calculateTotals() {
    double price = 0;
    double purchasePrice = 0;
    double quantity = 0;
    double paid = 0;

    _controllers.forEach((key, controller) {
      final String k = key.toLowerCase();

      final double value =
          double.tryParse(controller.text.trim()) ?? 0;

      if ((k.contains('سعر') && (k.contains('شراء') || k.contains('تكلفة'))) ||
          k.contains('purchase') ||
          k.contains('cost')) {
        purchasePrice = value;
      } else if (k.contains('سعر') ||
          k.contains('price') ||
          k.contains('قيمة')) {
        price = value;
      } else if (k.contains('كمية') ||
          k.contains('عدد') ||
          k.contains('quantity')) {
        quantity = value;
      } else if (k.contains('مدفوع') ||
          k.contains('واصل') ||
          k.contains('paid')) {
        paid = value;
      }
    });

    final double actualQuantity =
    quantity == 0 ? 1 : quantity;

    final double total =
        price * actualQuantity;

    final double remaining =
        total - paid;

    final double profit =
        (price - purchasePrice) * actualQuantity;

    _controllers.forEach((key, controller) {
      final String k = key.toLowerCase();

      if (k.contains('إجمالي') ||
          k.contains('اجمالي') ||
          k.contains('total')) {
        if (total > 0) {
          controller.text =
              total.toStringAsFixed(2);
        }
      } else if (k.contains('متبقي') ||
          k.contains('باقي') ||
          k.contains('remaining')) {
        controller.text =
            remaining.toStringAsFixed(2);
      } else if (k.contains('مكسب') ||
          k.contains('ربح') ||
          k.contains('profit')) {
        if (price > 0) {
          controller.text =
              profit.toStringAsFixed(2);
        }
      }
    });
  }

  // =========================================================
  // حفظ البيانات
  // =========================================================
  void _saveDataRecord() {
    final bool hasData = _controllers.values.any(
          (controller) =>
      controller.text.trim().isNotEmpty,
    );

    if (!hasData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'من فضلك ادخل بعض البيانات أولاً',
          ),
        ),
      );

      return;
    }

    final Map<String, String> newRecord = {};

    // تعبئة البيانات المدخلة من الـ Controllers
    _controllers.forEach((key, controller) {
      newRecord[key] = controller.text.trim();
    });

    // إضافة التاريخ والوقت تلقائياً في السجل إذا كان الجدول يحتوي على حقول مخصصة للتاريخ أو الوقت
    final DateTime now = DateTime.now();
    final String formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final String formattedTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    for (final attr in widget.category.selectedAttributes) {
      final String k = attr.toLowerCase();
      if (k.contains('تاريخ') || k.contains('date')) {
        newRecord[attr] = formattedDate;
      } else if (k.contains('وقت') || k.contains('time')) {
        newRecord[attr] = formattedTime;
      }
    }

    setState(() {
      // إضافة السجل
      _tableRecords.add(newRecord);

      // تحديث بيانات الـ Category
      widget.category.records =
          List.from(_tableRecords);

      // حفظ في Hive
      widget.category.save();

      // تنظيف الحقول
      for (final controller
      in _controllers.values) {
        controller.clear();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم إضافة وحفظ السجل بنجاح! 📊',
        ),
      ),
    );
  }

  // =========================================================
  // بناء الحقول
  // =========================================================
  Widget _buildFieldWidget(String attr) {
    final String lowerAttr =
    attr.toLowerCase();

    // إذا كان الحقل مخصصاً للتاريخ أو الوقت تلقائياً، فلا داعي لعرض حقل إدخال له لأن النظام سيقوم بملئه أوتوماتيكياً عند الحفظ
    if (lowerAttr.contains('تاريخ') || lowerAttr.contains('date') ||
        lowerAttr.contains('وقت') || lowerAttr.contains('time')) {
      return const SizedBox.shrink();
    }

    // =======================================================
    // هل الحقل خاص بمنتج؟
    // =======================================================
    final bool isProductField =
        lowerAttr.contains('منتج') ||
            lowerAttr.contains('صنف') ||
            lowerAttr.contains('item') ||
            lowerAttr.contains('product') ||
            lowerAttr.contains('القطعة') ||
            lowerAttr.contains('الاصناف');

    // =======================================================
    // هل الحقل خاص بعميل؟
    // =======================================================
    final bool isCustomerField =
        lowerAttr.contains('عميل') ||
            lowerAttr.contains('customer') ||
            lowerAttr.contains('زبون') ||
            (lowerAttr.contains('اسم') &&
                !isProductField);

    // =======================================================
    // حقل المنتج
    // =======================================================
    if (isProductField) {
      return Autocomplete<Product>(
        optionsBuilder:
            (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<Product>.empty();
          }

          return _productsBox.values.where(
                (Product product) {
              return product.name
                  .toLowerCase()
                  .contains(
                textEditingValue.text
                    .toLowerCase(),
              );
            },
          );
        },
        displayStringForOption:
            (Product product) => product.name,
        onSelected: (Product selection) {
          _controllers[attr]?.text =
              selection.name;

          // تعبئة سعر البيع وسعر الشراء بدقة منعاً لتداخل القيم
          _controllers.forEach(
                (key, controller) {
              final String k =
              key.toLowerCase();

              if ((k.contains('سعر') && (k.contains('شراء') || k.contains('تكلفة'))) ||
                  k.contains('purchase') ||
                  k.contains('cost')) {
                controller.text =
                    selection.purchasePrice.toString();
              } else if (k.contains('سعر') ||
                  k.contains('price') ||
                  k.contains('قيمة')) {
                controller.text =
                    selection.price.toString();
              }
            },
          );

          _calculateTotals();

          setState(() {});
        },
        fieldViewBuilder: (
            context,
            textController,
            focusNode,
            onFieldSubmitted,
            ) {
          if (_controllers[attr]!
              .text
              .isNotEmpty &&
              textController.text !=
                  _controllers[attr]!.text) {
            textController.text =
                _controllers[attr]!.text;
          }

          return TextField(
            controller: textController,
            focusNode: focusNode,
            onChanged: (value) {
              _controllers[attr]?.text =
                  value;

              _calculateTotals();
            },
            decoration: InputDecoration(
              labelText: attr,
              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(10),
              ),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          );
        },
      );
    }

    // =======================================================
    // حقل العميل
    // =======================================================
    if (isCustomerField) {
      return Autocomplete<Customer>(
        optionsBuilder:
            (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<Customer>.empty();
          }

          return _customersBox.values.where(
                (Customer customer) {
              return customer.name
                  .toLowerCase()
                  .contains(
                textEditingValue.text
                    .toLowerCase(),
              );
            },
          );
        },
        displayStringForOption:
            (Customer customer) =>
        customer.name,
        onSelected: (Customer selection) {
          _controllers[attr]?.text =
              selection.name;

          // تعبئة بيانات العميل تلقائياً
          _controllers.forEach(
                (key, controller) {
              final String k =
              key.toLowerCase();

              if (k.contains('هاتف') ||
                  k.contains('رقم') ||
                  k.contains('phone') ||
                  k.contains('موبايل')) {
                controller.text =
                    selection.phone;
              }

              if (k.contains('مدينة') ||
                  k.contains('عنوان') ||
                  k.contains('city')) {
                controller.text =
                    selection.city;
              }
            },
          );

          setState(() {});
        },
        fieldViewBuilder: (
            context,
            textController,
            focusNode,
            onFieldSubmitted,
            ) {
          if (_controllers[attr]!
              .text
              .isNotEmpty &&
              textController.text !=
                  _controllers[attr]!.text) {
            textController.text =
                _controllers[attr]!.text;
          }

          return TextField(
            controller: textController,
            focusNode: focusNode,
            onChanged: (value) {
              _controllers[attr]?.text =
                  value;
            },
            decoration: InputDecoration(
              labelText: attr,
              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(10),
              ),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          );
        },
      );
    }

    // =======================================================
    // الحقول العادية
    // =======================================================
    return TextField(
      controller: _controllers[attr],
      onChanged: (value) {
        _calculateTotals();
      },
      decoration: InputDecoration(
        labelText: attr,
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(10),
        ),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> attributes =
        widget.category.selectedAttributes;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.tableName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // =================================================
              // عنوان إدخال البيانات
              // =================================================
              const Text(
                'إدخال بيانات جديدة:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // =================================================
              // حقول الإدخال
              // =================================================
              SizedBox(
                height: 150,
                child: ListView(
                  children:
                  attributes.map((attr) {
                    return Padding(
                      padding:
                      const EdgeInsets.only(
                        bottom: 8,
                      ),
                      child:
                      _buildFieldWidget(attr),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 8),

              // =================================================
              // زر الإضافة
              // =================================================
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed:
                  _saveDataRecord,
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 21,
                  ),
                  label: const Text(
                    'إضافة للجدول',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.blue[700],
                    foregroundColor:
                    Colors.white,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Divider(
                thickness: 2,
              ),

              // =================================================
              // عنوان الجدول
              // =================================================
              const Text(
                'جدول البيانات:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // =================================================
              // الجدول
              // =================================================
              Expanded(
                child: _tableRecords.isEmpty
                    ? const Center(
                  child: Text(
                    'لا توجد بيانات مسجلة حتى الآن.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                )
                    : Container(
                  width:
                  double.infinity,
                  decoration:
                  BoxDecoration(
                    border: Border.all(
                      color: Colors
                          .grey.shade400,
                      width: 1.5,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                    // =================================================
                    // سكرول رأسي فقط
                    // =================================================
                    child:
                    SingleChildScrollView(
                      scrollDirection:
                      Axis.vertical,
                      child: LayoutBuilder(
                        builder:
                            (
                            context,
                            constraints,
                            ) {
                          return SizedBox(
                            width:
                            constraints
                                .maxWidth,
                            child: FittedBox(
                              fit: BoxFit
                                  .scaleDown,
                              alignment:
                              Alignment
                                  .topCenter,
                              child: Table(
                                // =================================================
                                // عرض الأعمدة ثابت زي الكود اللي بعتيه
                                // =================================================
                                defaultColumnWidth:
                                const FixedColumnWidth(
                                  120,
                                ),
                                columnWidths: {
                                  // عمود الترقيم
                                  0: const FixedColumnWidth(
                                    50,
                                  ),
                                  // باقي الأعمدة
                                  for (
                                  int i = 1;
                                  i <=
                                      attributes
                                          .length;
                                  i++
                                  )
                                    i:
                                    const FixedColumnWidth(
                                      120,
                                    ),
                                },
                                border:
                                TableBorder.all(
                                  color: Colors
                                      .grey
                                      .shade300,
                                  width: 1,
                                ),
                                defaultVerticalAlignment:
                                TableCellVerticalAlignment
                                    .middle,
                                children: [
                                  // =================================================
                                  // Header
                                  // =================================================
                                  TableRow(
                                    decoration:
                                    BoxDecoration(
                                      color: Colors
                                          .grey
                                          .shade200,
                                    ),
                                    children: [
                                      const SizedBox(
                                        width: 50,
                                        child:
                                        Padding(
                                          padding:
                                          EdgeInsets.symmetric(
                                            horizontal:
                                            6,
                                            vertical:
                                            14,
                                          ),
                                          child:
                                          Text(
                                            'م',
                                            textAlign:
                                            TextAlign
                                                .center,
                                            style:
                                            TextStyle(
                                              fontWeight:
                                              FontWeight
                                                  .bold,
                                              fontSize:
                                              16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      ...attributes
                                          .map(
                                            (attr) {
                                          return SizedBox(
                                            width:
                                            120,
                                            child:
                                            Padding(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                horizontal:
                                                8,
                                                vertical:
                                                14,
                                              ),
                                              child:
                                              Text(
                                                attr,
                                                textAlign:
                                                TextAlign
                                                    .center,
                                                softWrap:
                                                true,
                                                style:
                                                const TextStyle(
                                                  fontWeight:
                                                  FontWeight
                                                      .bold,
                                                  fontSize:
                                                  15,
                                                  height:
                                                  1.4,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  // =================================================
                                  // Data Rows
                                  // =================================================
                                  ...List.generate(
                                    _tableRecords
                                        .length,
                                        (index) {
                                      final record =
                                      _tableRecords[
                                      index];

                                      return TableRow(
                                        children: [
                                          // رقم الصف
                                          SizedBox(
                                            width:
                                            50,
                                            child:
                                            Padding(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                horizontal:
                                                6,
                                                vertical:
                                                14,
                                              ),
                                              child:
                                              Text(
                                                '${index + 1}',
                                                textAlign:
                                                TextAlign
                                                    .center,
                                                style:
                                                const TextStyle(
                                                  fontSize:
                                                  15,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // البيانات
                                          ...attributes
                                              .map(
                                                (attr) {
                                              final String?
                                              value =
                                              record[
                                              attr];

                                              return SizedBox(
                                                width:
                                                120,
                                                child:
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal:
                                                    8,
                                                    vertical:
                                                    14,
                                                  ),
                                                  child:
                                                  Text(
                                                    value?.isNotEmpty ==
                                                        true
                                                        ? value!
                                                        : '-',
                                                    textAlign:
                                                    TextAlign
                                                        .center,
                                                    softWrap:
                                                    true,
                                                    style:
                                                    const TextStyle(
                                                      fontSize:
                                                      15,
                                                      height:
                                                      1.4,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
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