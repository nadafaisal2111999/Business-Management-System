import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';
import 'saved_tables_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _tableNameController =
  TextEditingController();

  final List<String> _availableAttributes = [
    'اسم العميل (Customer Name)',
    'رقم الهاتف (Phone Number)',
    'المدينة (City)',
    'اسم الصنف (Item Name)',
    'المقاس (Size)',
    'اللون (Color)',
    'السعر (Price)',
    'الكمية (Quantity)',
    'الإجمالي (Total Amount)',
    'المبلغ المدفوع (Paid Amount)',
    'المبلغ المتبقي (Remaining Balance)',
    'الماركة / الموديل (Brand)',
    'تاريخ الإنتاج / الصلاحية (Expiry Date)',
    'ملحوظة (Note)',
    'التاريخ والوقت (Date & Time)',
    'سعر الشراء (Purchase Price)',
    'سعر البيع (Selling Price)',
    'المكسب (Profit)',
  ];

  final Set<String> _selectedAttributes = {};

  IconData _getIcon(String attribute) {
    if (attribute.contains('اسم العميل')) {
      return Icons.person_rounded;
    }

    if (attribute.contains('رقم الهاتف')) {
      return Icons.phone_rounded;
    }

    if (attribute.contains('المدينة')) {
      return Icons.location_on_rounded;
    }

    if (attribute.contains('اسم الصنف')) {
      return Icons.inventory_2_rounded;
    }

    if (attribute.contains('المقاس')) {
      return Icons.straighten_rounded;
    }

    if (attribute.contains('اللون')) {
      return Icons.palette_rounded;
    }

    if (attribute.contains('السعر')) {
      return Icons.sell_rounded;
    }

    if (attribute.contains('الكمية')) {
      return Icons.numbers_rounded;
    }

    if (attribute.contains('الإجمالي')) {
      return Icons.calculate_rounded;
    }

    if (attribute.contains('المبلغ المدفوع')) {
      return Icons.payments_rounded;
    }

    if (attribute.contains('المبلغ المتبقي')) {
      return Icons.account_balance_wallet_rounded;
    }

    if (attribute.contains('الماركة')) {
      return Icons.branding_watermark_rounded;
    }

    if (attribute.contains('تاريخ الإنتاج')) {
      return Icons.calendar_month_rounded;
    }

    if (attribute.contains('ملحوظة')) {
      return Icons.notes_rounded;
    }

    if (attribute.contains('التاريخ والوقت')) {
      return Icons.access_time_rounded;
    }

    if (attribute.contains('سعر الشراء')) {
      return Icons.shopping_bag_rounded;
    }

    if (attribute.contains('سعر البيع')) {
      return Icons.sell_rounded;
    }

    if (attribute.contains('المكسب')) {
      return Icons.trending_up_rounded;
    }

    return Icons.data_object_rounded;
  }

  Color _getColor(String attribute) {
    if (attribute.contains('اسم العميل')) {
      return const Color(0xFF1976D2);
    }

    if (attribute.contains('رقم الهاتف')) {
      return const Color(0xFF3949AB);
    }

    if (attribute.contains('المدينة')) {
      return const Color(0xFF00897B);
    }

    if (attribute.contains('اسم الصنف')) {
      return const Color(0xFFEF6C00);
    }

    if (attribute.contains('المقاس')) {
      return const Color(0xFF8E24AA);
    }

    if (attribute.contains('اللون')) {
      return const Color(0xFFE91E63);
    }

    if (attribute.contains('السعر')) {
      return const Color(0xFF2E7D32);
    }

    if (attribute.contains('الكمية')) {
      return const Color(0xFF00838F);
    }

    if (attribute.contains('الإجمالي')) {
      return const Color(0xFF00695C);
    }

    if (attribute.contains('المبلغ المدفوع')) {
      return const Color(0xFF43A047);
    }

    if (attribute.contains('المبلغ المتبقي')) {
      return const Color(0xFFD84315);
    }

    if (attribute.contains('الماركة')) {
      return const Color(0xFF5E35B1);
    }

    if (attribute.contains('تاريخ الإنتاج')) {
      return const Color(0xFF546E7A);
    }

    if (attribute.contains('ملحوظة')) {
      return const Color(0xFF6D4C41);
    }

    if (attribute.contains('التاريخ والوقت')) {
      return const Color(0xFF1565C0);
    }

    if (attribute.contains('سعر الشراء')) {
      return const Color(0xFFC62828);
    }

    if (attribute.contains('سعر البيع')) {
      return const Color(0xFF2E7D32);
    }

    if (attribute.contains('المكسب')) {
      return const Color(0xFF00897B);
    }

    return const Color(0xFF00897B);
  }

  void _saveCustomTable() {
    FocusScope.of(context).unfocus();

    final tableName = _tableNameController.text.trim();

    if (tableName.isEmpty) {
      _showMessage(
        'من فضلك اكتب اسم الجدول أو الفاتورة',
        Icons.edit_rounded,
        const Color(0xFFE65100),
      );
      return;
    }

    if (_selectedAttributes.isEmpty) {
      _showMessage(
        'اختار على الأقل حقل واحد للجدول',
        Icons.checklist_rounded,
        const Color(0xFFE65100),
      );
      return;
    }

    final box = Hive.box<CategoryModel>('categoriesBox');

    final newCategory = CategoryModel(
      tableName: tableName,
      selectedAttributes: List<String>.from(_selectedAttributes),
    );

    box.add(newCategory);

    _tableNameController.clear();

    setState(() {
      _selectedAttributes.clear();
    });

    _showMessage(
      'تم إنشاء الجدول بنجاح 🎉',
      Icons.check_circle_rounded,
      const Color(0xFF2E7D32),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SavedTablesScreen(),
        ),
      );
    });
  }

  void _showMessage(
      String message,
      IconData icon,
      Color color,
      ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        elevation: 8,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFF263238),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tableNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    int columns;

    if (width >= 1300) {
      columns = 4;
    } else if (width >= 900) {
      columns = 3;
    } else if (width >= 600) {
      columns = 2;
    } else {
      columns = 1;
    }

    final bool isMobile = width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF173F3A),
        centerTitle: false,
        titleSpacing: isMobile ? 14 : 22,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF00897B).withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.table_view_rounded,
                color: Color(0xFF00897B),
                size: 22,
              ),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Text(
                'منشئ الجداول',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 14 : 28,
            vertical: 22,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1450,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BuilderHero(
                    selectedCount: _selectedAttributes.length,
                  ),

                  const SizedBox(height: 22),

                  _TableNameCard(
                    controller: _tableNameController,
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 25,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00897B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'اختار الحقول',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF263238),
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'حدد البيانات اللي عايزها تظهر في الجدول',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF78909C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedAttributes.isEmpty
                              ? Colors.white
                              : const Color(0xFF00897B)
                              .withOpacity(0.10),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedAttributes.isEmpty
                                ? Colors.grey.withOpacity(0.12)
                                : const Color(0xFF00897B)
                                .withOpacity(0.20),
                          ),
                        ),
                        child: Text(
                          '${_selectedAttributes.length} مختار',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _selectedAttributes.isEmpty
                                ? const Color(0xFF78909C)
                                : const Color(0xFF00897B),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  GridView.builder(
                    shrinkWrap: true,
                    physics:
                    const NeverScrollableScrollPhysics(),
                    itemCount: _availableAttributes.length,
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: isMobile ? 88 : 92,
                    ),
                    itemBuilder: (context, index) {
                      final attribute =
                      _availableAttributes[index];

                      return _AttributeCard(
                        title: attribute,
                        icon: _getIcon(attribute),
                        color: _getColor(attribute),
                        selected: _selectedAttributes
                            .contains(attribute),
                        onTap: () {
                          setState(() {
                            if (_selectedAttributes
                                .contains(attribute)) {
                              _selectedAttributes
                                  .remove(attribute);
                            } else {
                              _selectedAttributes
                                  .add(attribute);
                            }
                          });
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 22),

                  if (_selectedAttributes.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00897B)
                            .withOpacity(0.06),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFF00897B)
                              .withOpacity(0.12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00897B)
                                  .withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Color(0xFF00897B),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'تم اختيار ${_selectedAttributes.length} حقل للجدول',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF00695C),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedAttributes.clear();
                              });
                            },
                            child: const Text(
                              'مسح الكل',
                              style: TextStyle(
                                color: Color(0xFFE53935),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _saveCustomTable,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor:
                        const Color(0xFF00897B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 23,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _selectedAttributes.isEmpty
                                ? 'حفظ هيكل الجدول'
                                : 'إنشاء الجدول • ${_selectedAttributes.length} حقول',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Center(
                    child: Text(
                      'يمكنك تعديل الجدول لاحقاً من الجداول المحفوظة',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF90A4AE),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================
// HERO
// =============================================================

class _BuilderHero extends StatelessWidget {
  final int selectedCount;

  const _BuilderHero({
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 19 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF004D40),
            Color(0xFF00796B),
            Color(0xFF26A69A),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.20),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -40,
            top: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -40,
            bottom: -70,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: isMobile ? 58 : 68,
                height: isMobile ? 58 : 68,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                child: Icon(
                  Icons.dashboard_customize_rounded,
                  color: Colors.white,
                  size: isMobile ? 30 : 36,
                ),
              ),
              SizedBox(width: isMobile ? 13 : 17),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'صمّم جدولك بنفسك ✨',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'منشئ الجداول والفواتير',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      selectedCount == 0
                          ? 'اختار الحقول اللي تناسب شغلك'
                          : 'تم اختيار $selectedCount حقول',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================
// TABLE NAME CARD
// =============================================================

class _TableNameCard extends StatelessWidget {
  final TextEditingController controller;

  const _TableNameCard({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF00897B)
                      .withOpacity(0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: Color(0xFF00897B),
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اسم الجدول',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF263238),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'اكتب اسم مناسب للجدول أو الفاتورة',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF78909C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText:
              'مثال: فاتورة مبيعات، سجل العملاء...',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFF90A4AE),
              ),
              prefixIcon: const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFF00897B),
              ),
              filled: true,
              fillColor: const Color(0xFFF7F9FA),
              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.10),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFF00897B),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// ATTRIBUTE CARD
// =============================================================

class _AttributeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _AttributeCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(0.07)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? color.withOpacity(0.35)
                : Colors.grey.withOpacity(0.10),
            width: selected ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? color.withOpacity(0.08)
                  : Colors.black.withOpacity(0.025),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withOpacity(0.70),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 23,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.25,
                  fontWeight:
                  selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected
                      ? color
                      : const Color(0xFF37474F),
                ),
              ),
            ),
            const SizedBox(width: 7),
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: selected
                    ? color
                    : const Color(0xFFF3F6F8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? color
                      : Colors.grey.withOpacity(0.18),
                ),
              ),
              child: selected
                  ? const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 17,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}