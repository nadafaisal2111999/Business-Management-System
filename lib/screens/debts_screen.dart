import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/category_model.dart';
import 'person_details_screen.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // هيكل لتخزين معلومات الشخص وجدواله وديونه (مع استبعاد من تم سداد ديونهم بالكامل)
  Map<String, PersonData> _getDebtsAndCategories(String boxName, bool isSupplier) {
    Map<String, PersonData> personMap = {};

    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box<CategoryModel>(boxName);
        for (var category in box.values) {
          Map<String, double> categoryDebts = {};

          for (var record in category.records) {
            String personName = '';
            double remainingAmount = 0.0;

            record.forEach((key, value) {
              String k = key.toLowerCase();
              String val = value.trim();

              if (isSupplier) {
                if ((k.contains('مورد') || k.contains('supplier') || (k.contains('اسم') && !k.contains('منتج') && !k.contains('صنف'))) && val.isNotEmpty) {
                  if (!val.toLowerCase().contains('iphon') && !val.toLowerCase().contains('ايفون')) {
                    personName = val;
                  }
                }
              } else {
                if ((k.contains('عميل') || k.contains('customer') || (k.contains('اسم') && !k.contains('منتج') && !k.contains('صنف'))) && val.isNotEmpty) {
                  if (!val.toLowerCase().contains('iphon') && !val.toLowerCase().contains('ايفون')) {
                    personName = val;
                  }
                }
              }

              if (k.contains('متبقي') || k.contains('باقي') || k.contains('remaining')) {
                remainingAmount = double.tryParse(val) ?? 0.0;
              }
            });

            if (personName.isNotEmpty) {
              categoryDebts[personName] = (categoryDebts[personName] ?? 0.0) + remainingAmount;
            }
          }

          // تجميع الجداول لكل شخص
          categoryDebts.forEach((name, debt) {
            if (!personMap.containsKey(name)) {
              personMap[name] = PersonData(name: name, totalDebt: 0.0, categories: []);
            }
            personMap[name]!.totalDebt += debt;
            if (!personMap[name]!.categories.contains(category)) {
              personMap[name]!.categories.add(category);
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    }

    // تصفية القائمة بحيث يتم إزالة أي شخص أصبح إجمالي دينه صفر أو أقل (ليختفي تماماً)
    personMap.removeWhere((key, person) => person.totalDebt <= 0);

    return personMap;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, PersonData> suppliersData = _getDebtsAndCategories('purchaseCategoriesBox', true);
    double totalSuppliersDebt = suppliersData.values.fold(0.0, (sum, item) => sum + item.totalDebt);

    Map<String, PersonData> customersData = _getDebtsAndCategories('categoriesBox', false);
    double totalCustomersDebt = customersData.values.fold(0.0, (sum, item) => sum + item.totalDebt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير المديونيات (الحسابات)'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: const [
            Tab(text: 'فلوس عليا (للموردين)'),
            Tab(text: 'فلوس ليا (عند العملاء)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPersonsList(
            title: 'إجمالي الفلوس اللي عليا للموردين',
            totalAmount: totalSuppliersDebt,
            personsData: suppliersData,
            color: Colors.red[700]!,
            emptyMessage: 'لا توجد مبالغ مستحقة عليك للموردين حالياً.',
          ),
          _buildPersonsList(
            title: 'إجمالي الفلوس اللي ليا عند العملاء',
            totalAmount: totalCustomersDebt,
            personsData: customersData,
            color: Colors.green[700]!,
            emptyMessage: 'لا توجد مبالغ مستحقة لك عند العملاء حالياً.',
          ),
        ],
      ),
    );
  }

  Widget _buildPersonsList({
    required String title,
    required double totalAmount,
    required Map<String, PersonData> personsData,
    required Color color,
    required String emptyMessage,
  }) {
    List<PersonData> list = personsData.values.toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 8),
                Text(
                  '${totalAmount.toStringAsFixed(2)} جنيه',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'التفاصيل حسب الأسماء (اضغطي على الاسم لعرض الفواتير):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: list.isEmpty
                ? Center(
              child: Text(
                emptyMessage,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
                : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                PersonData person = list[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      person.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    subtitle: Text('عدد الجداول المرتبطة: ${person.categories.length}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${person.totalDebt.toStringAsFixed(2)} جنيه',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                      ],
                    ),
                    onTap: () async {
                      // الانتقال لصفحة تفاصيل الشخص وانتظار الرجوع لتحديث الصفحة تلقائياً
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PersonDetailsScreen(
                            personName: person.name,
                            personCategories: person.categories,
                            themeColor: color,
                          ),
                        ),
                      );
                      // إعادة بناء الشاشة فور الرجوع لتحديث القائمة واختفاء الاسم المسدد دينه
                      setState(() {});
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PersonData {
  final String name;
  double totalDebt;
  final List<CategoryModel> categories;

  PersonData({
    required this.name,
    required this.totalDebt,
    required this.categories,
  });
}