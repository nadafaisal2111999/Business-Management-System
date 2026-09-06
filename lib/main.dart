import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/category_model.dart';
import 'models/customer_model.dart';
import 'models/product_model.dart';
import 'models/sale_model.dart';
import 'models/purchase_invoice_model.dart';
import 'models/purchase_item_model.dart';
import 'models/purchase_model.dart';
import 'models/supplier_model.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  // التأكد من تهيئة بيئة الفلاتر قبل تشغيل أي شيء يخص الـ Native
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة مكتبة Hive داخل التطبيق
  await Hive.initFlutter();

  // تسجيل الـ Adapters الخاصة بالنماذج (Models) مع التحقق من عدم تسجيلها مسبقاً تفادياً للأخطاء
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(CustomerAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ProductAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SaleItemAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(PurchaseInvoiceAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(PurchaseItemAdapter());
  if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(CategoryModelAdapter());
  if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(SupplierPurchaseAdapter());

  // إذا كان SupplierModelAdapter غير مسجل برقم تالي، سيتم تسجيله بأمان:
  try {
    Hive.registerAdapter(SupplierModelAdapter());
  } catch (_) {
    // تم تسجيله مسبقاً أو تم تجاهله لتجنب تعارض الـ TypeId
  }

  // فتح صناديق Hive (Boxes) لتكون جاهزة للقراءة والكتابة
  await Hive.openBox<Customer>('customersBox');
  await Hive.openBox<Product>('productsBox');
  await Hive.openBox<SaleItem>('salesBox');
  await Hive.openBox<PurchaseInvoice>('purchaseInvoicesBox');
  await Hive.openBox<PurchaseItem>('purchaseItemsBox');
  await Hive.openBox<CategoryModel>('categoriesBox'); // صندوق جداول المبيعات
  await Hive.openBox<CategoryModel>('purchaseCategoriesBox'); // صندوق جداول المشتريات المنفصل
  await Hive.openBox<SupplierPurchase>('purchases_box');
  await Hive.openBox<SupplierModel>('suppliersBox'); // فتح صندوق الموردين

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'دفتر المحل',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}