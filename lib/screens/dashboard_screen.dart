import 'package:flutter/material.dart';
import 'package:newapp/screens/profits_screen.dar.dart';
import 'categories_screen.dart';
import 'products_screen.dart';
import 'saved_tables_screen.dart';
import 'saved_purchase_tables_screen.dart';
import 'suppliers_screen.dart';
import 'customers_screen.dart';
import 'debts_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    int columns;
    double aspectRatio;

    if (width >= 1400) {
      columns = 4;
      aspectRatio = 1.05;
    } else if (width >= 1000) {
      columns = 4;
      aspectRatio = 0.95;
    } else if (width >= 700) {
      columns = 3;
      aspectRatio = 0.95;
    } else {
      columns = 2;
      aspectRatio = 0.88;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F8),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF173F3A),
        centerTitle: false,
        titleSpacing: 22,
        title: const Row(
          children: [
            Icon(
              Icons.storefront_rounded,
              color: Color(0xFF00897B),
              size: 28,
            ),
            SizedBox(width: 10),
            Text(
              'دفتر المحل',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: width < 600 ? 14 : 28,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeroSection(),

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

                  const Text(
                    'إدارة المحل',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF263238),
                    ),
                  ),

                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.12),
                      ),
                    ),
                    child: const Text(
                      '8 خدمات',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF607D8B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: columns,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: aspectRatio,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _DashboardCard(
                    title: 'العملاء',
                    subtitle: 'إدارة بيانات العملاء',
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFF1976D2),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomersScreen(),
                        ),
                      );
                    },
                  ),

                  _DashboardCard(
                    title: 'الموردين',
                    subtitle: 'إدارة الموردين',
                    icon: Icons.local_shipping_rounded,
                    color: const Color(0xFF3949AB),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SuppliersScreen(),
                        ),
                      );
                    },
                  ),

                  _DashboardCard(
                    title: 'المنتجات',
                    subtitle: 'المنتجات والأسعار',
                    icon: Icons.inventory_2_rounded,
                    color: const Color(0xFFEF6C00),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductsScreen(),
                        ),
                      );
                    },
                  ),

                  _DashboardCard(
                    title: 'المشتريات',
                    subtitle: 'عمليات الشراء',
                    icon: Icons.shopping_cart_rounded,
                    color: const Color(0xFFE53935),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const SavedPurchaseTablesScreen(),
                        ),
                      );
                    },
                  ),

                  _DashboardCard(
                    title: 'إنشاء جدول',
                    subtitle: 'صمم جدولك الخاص',
                    icon: Icons.add_chart_rounded,
                    color: const Color(0xFF8E24AA),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CategoriesScreen(),
                        ),
                      );
                    },
                  ),

                  _DashboardCard(
                    title: 'جداول المبيعات',
                    subtitle: 'عرض وإدارة المبيعات',
                    icon: Icons.table_chart_rounded,
                    color: const Color(0xFF2E7D32),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavedTablesScreen(),
                        ),
                      );
                    },
                  ),

                  _DashboardCard(
                    title: 'الديون والحسابات',
                    subtitle: 'الحسابات والديون',
                    icon: Icons.account_balance_wallet_rounded,
                    color: const Color(0xFF00897B),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DebtsScreen(),
                        ),
                      );
                    },
                  ),

                  _DashboardCard(
                    title: 'الأرباح والمكسب',
                    subtitle: 'تحليل الأرباح والتقارير',
                    icon: Icons.analytics_rounded,
                    color: const Color(0xFF00695C),
                    isSpecial: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfitsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.10),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00897B).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: Color(0xFF00897B),
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Text(
                        'جميع بيانات المحل محفوظة محلياً على جهازك',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF607D8B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF43A047),
                      size: 20,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// HERO SECTION
// =============================================================

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isSmall = width < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 18 : 24),
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
        borderRadius: BorderRadius.circular(28),
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
            left: -35,
            top: -45,
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
            right: 80,
            bottom: -70,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: isSmall ? 58 : 68,
                height: isSmall ? 58 : 68,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: isSmall ? 31 : 37,
                ),
              ),

              SizedBox(width: isSmall ? 12 : 17),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'أهلاً بيك 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'لوحة التحكم',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'كل أدوات المحل في مكان واحد',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
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
// DASHBOARD CARD
// =============================================================

class _DashboardCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isSpecial;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isSpecial = false,
  });

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onTapDown: (_) {
        setState(() => pressed = true);
      },

      onTapCancel: () {
        setState(() => pressed = false);
      },

      onTapUp: (_) {
        setState(() => pressed = false);
        widget.onTap();
      },

      child: AnimatedScale(
        scale: pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),

        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),

            border: Border.all(
              color: widget.color.withOpacity(
                widget.isSpecial ? 0.22 : 0.08,
              ),
              width: widget.isSpecial ? 1.3 : 1,
            ),

            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(
                  widget.isSpecial ? 0.12 : 0.055,
                ),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),

            child: Stack(
              children: [
                // ===================================================
                // BACKGROUND DECORATION
                // ===================================================

                Positioned(
                  right: -35,
                  top: -35,
                  child: Container(
                    width: 105,
                    height: 105,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.045),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                Positioned(
                  left: -25,
                  bottom: -35,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.025),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // ===================================================
                // CONTENT
                // ===================================================

                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ICON
                        Container(
                          width: 52,
                          height: 52,

                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.color,
                                widget.color.withOpacity(0.72),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),

                            borderRadius: BorderRadius.circular(16),

                            boxShadow: [
                              BoxShadow(
                                color: widget.color.withOpacity(0.20),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),

                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // TITLE
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF263238),
                          ),
                        ),

                        const SizedBox(height: 5),

                        // SUBTITLE
                        Text(
                          widget.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            height: 1.35,
                            color: Color(0xFF78909C),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const Spacer(),

                        // BOTTOM
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 3,
                              decoration: BoxDecoration(
                                color: widget.color,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),

                            const Spacer(),

                            Container(
                              width: 27,
                              height: 27,
                              decoration: BoxDecoration(
                                color:
                                widget.color.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 11,
                                color: widget.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ===================================================
                // SPECIAL BADGE
                // ===================================================

                if (widget.isSpecial)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            color: Colors.green,
                            size: 12,
                          ),

                          SizedBox(width: 3),

                          Text(
                            'تحليل',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}