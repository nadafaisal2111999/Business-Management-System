import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_model.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late Box<Product> _productsBox;

  @override
  void initState() {
    super.initState();
    _productsBox = Hive.box<Product>('productsBox');
  }

  // نافذة إضافة منتج جديد (مستقلة تماماً لمنع تداخل الحقول)
  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddProductDialogWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'دفتر المنتجات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<Box<Product>>(
        valueListenable: _productsBox.listenable(),
        builder: (context, box, _) {
          final products = box.values.toList();

          if (products.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد منتجات مسجلة حتى الآن.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              children: [
                                Text(
                                  'سعر البيع: ${product.price} ج.م',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'سعر الشراء: ${product.purchasePrice} ج.م',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          product.delete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// كلاس مستقل للديالوج لضمان استقلالية الـ Controllers وتدميرها بشكل صحيح
class _AddProductDialogWidget extends StatefulWidget {
  const _AddProductDialogWidget();

  @override
  State<_AddProductDialogWidget> createState() => _AddProductDialogWidgetState();
}

class _AddProductDialogWidgetState extends State<_AddProductDialogWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();
  final TextEditingController _purchasePriceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _sellingPriceController.dispose();
    _purchasePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'إضافة منتج جديد',
        textAlign: TextAlign.right,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'اسم المنتج',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                isDense: true,
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _sellingPriceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'سعر البيع',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                isDense: true,
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _purchasePriceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'سعر الشراء',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                isDense: true,
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            final String name = _nameController.text.trim();
            final double sellingPrice =
                double.tryParse(_sellingPriceController.text.trim()) ?? 0.0;
            final double purchasePrice =
                double.tryParse(_purchasePriceController.text.trim()) ?? 0.0;

            if (name.isNotEmpty) {
              final productsBox = Hive.box<Product>('productsBox');
              final newProduct = Product(
                name: name,
                price: sellingPrice,
                purchasePrice: purchasePrice,
              );

              productsBox.add(newProduct);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}