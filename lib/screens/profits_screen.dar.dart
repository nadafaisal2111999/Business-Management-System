import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/category_model.dart';

class ProfitsScreen extends StatefulWidget {
  const ProfitsScreen({super.key});

  @override
  State<ProfitsScreen> createState() => _ProfitsScreenState();
}

class _ProfitsScreenState extends State<ProfitsScreen> {
  // =========================================================
  // تحويل النص إلى رقم
  // =========================================================
  double _toDouble(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 0;
    }

    String text = value
        .trim()
        .replaceAll(',', '')
        .replaceAll('،', '')
        .replaceAll('جنيه', '')
        .replaceAll('ج', '')
        .trim();

    return double.tryParse(text) ?? 0;
  }

  // =========================================================
  // هل الحقل هو سعر البيع؟
  // =========================================================
  bool _isSellingPrice(String key) {
    final k = key.toLowerCase().trim();

    if (k.contains('شراء') ||
        k.contains('تكلفة') ||
        k.contains('purchase') ||
        k.contains('cost')) {
      return false;
    }

    return k.contains('سعر البيع') ||
        k == 'سعر' ||
        k.contains('سعر البيع') ||
        k.contains('price') ||
        k.contains('بيع');
  }

  // =========================================================
  // هل الحقل هو سعر الشراء؟
  // =========================================================
  bool _isPurchasePrice(String key) {
    final k = key.toLowerCase().trim();

    return k.contains('سعر شراء') ||
        k.contains('سعر الشراء') ||
        k.contains('شراء') ||
        k.contains('تكلفة') ||
        k.contains('purchase') ||
        k.contains('cost');
  }

  // =========================================================
  // هل الحقل كمية؟
  // =========================================================
  bool _isQuantity(String key) {
    final k = key.toLowerCase().trim();

    return k.contains('كمية') ||
        k.contains('عدد') ||
        k.contains('quantity') ||
        k == 'qty';
  }

  // =========================================================
  // هل الحقل مكسب؟
  // =========================================================
  bool _isProfitField(String key) {
    final k = key.toLowerCase().trim();

    return k == 'مكسب' ||
        k == 'المكسب' ||
        k.contains('مكسب') ||
        k.contains('ربح') ||
        k.contains('profit');
  }

  // =========================================================
  // حساب ربح سجل واحد
  // =========================================================
  double _calculateRecordProfit(
      Map<String, String> record,
      ) {
    // إذا كان المكسب محفوظاً بالفعل نستخدمه
    for (final entry in record.entries) {
      if (_isProfitField(entry.key)) {
        if (entry.value.trim().isNotEmpty) {
          return _toDouble(entry.value);
        }
      }
    }

    double sellingPrice = 0;
    double purchasePrice = 0;
    double quantity = 1;

    for (final entry in record.entries) {
      final key = entry.key;
      final value = _toDouble(entry.value);

      if (_isPurchasePrice(key)) {
        purchasePrice = value;
      } else if (_isSellingPrice(key)) {
        sellingPrice = value;
      } else if (_isQuantity(key)) {
        quantity = value == 0 ? 1 : value;
      }
    }

    return (sellingPrice - purchasePrice) * quantity;
  }

  // =========================================================
  // حساب أرباح الجداول
  // =========================================================
  Map<String, double> _calculateProfits() {
    final Map<String, double> profits = {};

    try {
      if (!Hive.isBoxOpen('categoriesBox')) {
        return profits;
      }

      final box = Hive.box<CategoryModel>('categoriesBox');

      for (final category in box.values) {
        double tableProfit = 0;

        for (final record in category.records) {
          tableProfit += _calculateRecordProfit(record);
        }

        String tableName = category.tableName.trim();

        if (tableName.isEmpty) {
          tableName = 'جدول';
        }

        String uniqueName = tableName;
        int counter = 1;

        while (profits.containsKey(uniqueName)) {
          uniqueName = '$tableName ($counter)';
          counter++;
        }

        profits[uniqueName] = tableProfit;
      }
    } catch (e) {
      debugPrint('Error calculating profits: $e');
    }

    return profits;
  }

  // =========================================================
  // تنسيق الأرقام
  // =========================================================
  String _formatMoney(double value) {
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value.abs() >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  // =========================================================
  // أعلى جدول
  // =========================================================
  String _getBestTable(Map<String, double> profits) {
    if (profits.isEmpty) {
      return 'لا يوجد';
    }

    final entry = profits.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
    );

    return entry.key;
  }

  // =========================================================
  // أعلى ربح
  // =========================================================
  double _getBestProfit(Map<String, double> profits) {
    if (profits.isEmpty) {
      return 0;
    }

    return profits.values.reduce(
          (a, b) => a > b ? a : b,
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<CategoryModel>('categoriesBox');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'تقرير الأرباح',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ValueListenableBuilder<Box<CategoryModel>>(
        valueListenable: box.listenable(),

        builder: (context, categoriesBox, child) {
          final profits = _calculateProfits();

          final totalProfit = profits.values.fold(
            0.0,
                (sum, value) => sum + value,
          );

          final bestTable = _getBestTable(profits);

          final bestProfit = _getBestProfit(profits);

          // ===================================================
          // تحديد مدى الرسم
          // ===================================================
          double maxProfit = 100;

          if (profits.isNotEmpty) {
            final values = profits.values.toList();

            double maxValue = values.reduce(
                  (a, b) => a > b ? a : b,
            );

            if (maxValue > 0) {
              maxProfit = maxValue * 1.25;
            }

            if (maxProfit < 100) {
              maxProfit = 100;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // =================================================
                // كارت إجمالي الأرباح
                // =================================================
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 26,
                  ),

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF00897B),
                        Color(0xFF26A69A),
                      ],

                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),

                    borderRadius: BorderRadius.circular(24),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.22),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      Container(
                        width: 58,
                        height: 58,

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.trending_up,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'إجمالي الأرباح',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        '${totalProfit.toStringAsFixed(2)} جنيه',

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: const Text(
                          'صافي الربح من الجداول',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // =================================================
                // الإحصائيات
                // =================================================
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.table_chart,
                        title: 'الجداول',
                        value: '${profits.length}',
                        subtitle: 'جدول',
                        iconColor: Colors.blue,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _InfoCard(
                        icon: Icons.workspace_premium,
                        title: 'أعلى ربح',
                        value: _formatMoney(bestProfit),
                        subtitle: 'جنيه',
                        iconColor: Colors.orange,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _InfoCard(
                        icon: Icons.show_chart,
                        title: 'الحالة',
                        value: totalProfit >= 0
                            ? 'موجب'
                            : 'سالب',
                        subtitle: 'الربح',
                        iconColor: totalProfit >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // =================================================
                // عنوان الرسم
                // =================================================
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: [
                    const Text(
                      'الأرباح حسب الجداول',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF263238),
                      ),
                    ),

                    if (profits.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius:
                          BorderRadius.circular(10),
                        ),

                        child: Text(
                          '${profits.length} جداول',
                          style: const TextStyle(
                            color: Colors.teal,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // =================================================
                // الرسم البياني
                // =================================================
                if (profits.isEmpty)
                  Container(
                    width: double.infinity,
                    height: 360,

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Icon(
                            Icons.bar_chart,
                            size: 60,
                            color: Colors.grey,
                          ),

                          SizedBox(height: 12),

                          Text(
                            'لا توجد بيانات أرباح حتى الآن',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            'أضف بيانات للمبيعات لعرض الرسم',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 430,

                    padding: const EdgeInsets.fromLTRB(
                      8,
                      25,
                      18,
                      15,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(22),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: BarChart(
                      BarChartData(
                        minY: 0,

                        maxY: maxProfit,

                        alignment:
                        BarChartAlignment.spaceAround,

                        groupsSpace: 18,

                        // =================================================
                        // التفاعل
                        // =================================================
                        barTouchData: BarTouchData(
                          enabled: true,

                          touchTooltipData:
                          BarTouchTooltipData(
                            tooltipBorderRadius: BorderRadius.circular(12),

                            tooltipPadding:
                            const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),

                            getTooltipItem: (
                                group,
                                groupIndex,
                                rod,
                                rodIndex,
                                ) {
                              final names =
                              profits.keys.toList();

                              if (groupIndex < 0 ||
                                  groupIndex >= names.length) {
                                return null;
                              }

                              return BarTooltipItem(
                                '${names[groupIndex]}\n'
                                    '${rod.toY.toStringAsFixed(2)} جنيه',

                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),

                        // =================================================
                        // العناوين
                        // =================================================
                        titlesData: FlTitlesData(
                          show: true,

                          topTitles:
                          const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),

                          rightTitles:
                          const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),

                          // =================================================
                          // محور Y
                          // =================================================
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,

                              reservedSize: 48,

                              interval: maxProfit / 5,

                              getTitlesWidget:
                                  (value, meta) {
                                return Text(
                                  _formatMoney(value),

                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                );
                              },
                            ),
                          ),

                          // =================================================
                          // أسماء الجداول
                          // =================================================
                          bottomTitles:
                          AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,

                              reservedSize: 65,

                              getTitlesWidget:
                                  (value, meta) {
                                final index =
                                value.toInt();

                                final names =
                                profits.keys.toList();

                                if (index < 0 ||
                                    index >=
                                        names.length) {
                                  return const SizedBox();
                                }

                                final name =
                                names[index];

                                return Padding(
                                  padding:
                                  const EdgeInsets.only(
                                    top: 12,
                                  ),

                                  child: SizedBox(
                                    width: 75,

                                    child: Text(
                                      name.length > 10
                                          ? '${name.substring(0, 10)}...'
                                          : name,

                                      textAlign:
                                      TextAlign.center,

                                      maxLines: 2,

                                      overflow:
                                      TextOverflow.ellipsis,

                                      style:
                                      const TextStyle(
                                        fontSize: 10,
                                        fontWeight:
                                        FontWeight.bold,
                                        color:
                                        Color(0xFF455A64),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // =================================================
                        // خطوط الشبكة
                        // =================================================
                        gridData: FlGridData(
                          show: true,

                          drawVerticalLine: false,

                          horizontalInterval:
                          maxProfit / 5,

                          getDrawingHorizontalLine:
                              (value) {
                            return FlLine(
                              color:
                              Colors.grey.withOpacity(0.12),
                              strokeWidth: 1,
                            );
                          },
                        ),

                        borderData:
                        FlBorderData(
                          show: false,
                        ),

                        // =================================================
                        // الأعمدة
                        // =================================================
                        barGroups: profits.entries
                            .toList()
                            .asMap()
                            .entries
                            .map(
                              (entry) {
                            final index =
                                entry.key;

                            final profit =
                                entry.value.value;

                            return BarChartGroupData(
                              x: index,

                              showingTooltipIndicators:
                              const [],

                              barRods: [
                                BarChartRodData(
                                  toY: profit,

                                  width: 32,

                                  color: profit >= 0
                                      ? Colors.teal
                                      : Colors.redAccent,

                                  borderRadius:
                                  const BorderRadius.only(
                                    topLeft:
                                    Radius.circular(8),
                                    topRight:
                                    Radius.circular(8),
                                  ),

                                  backDrawRodData:
                                  BackgroundBarChartRodData(
                                    show: true,

                                    toY: maxProfit,

                                    color: Colors.grey
                                        .withOpacity(0.035),
                                  ),
                                ),
                              ],
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // =================================================
                // أفضل جدول
                // =================================================
                if (profits.isNotEmpty)
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(18),

                      border: Border.all(
                        color:
                        Colors.orange.withOpacity(0.2),
                      ),
                    ),

                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,

                          decoration: BoxDecoration(
                            color:
                            Colors.orange.withOpacity(0.12),
                            borderRadius:
                            BorderRadius.circular(14),
                          ),

                          child: const Icon(
                            Icons.emoji_events,
                            color: Colors.orange,
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [
                              const Text(
                                'أعلى جدول تحقيقًا للربح',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                bestTable,
                                maxLines: 1,
                                overflow:
                                TextOverflow.ellipsis,

                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          '${bestProfit.toStringAsFixed(2)} ج',
                          style: const TextStyle(
                            color: Colors.teal,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =============================================================
// كارت الإحصائية الصغيرة
// =============================================================
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color iconColor;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 105,

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,

                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius:
                  BorderRadius.circular(9),
                ),

                child: Icon(
                  icon,
                  size: 18,
                  color: iconColor,
                ),
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.end,

            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,

                  style: TextStyle(
                    color: iconColor,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 3),

              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}