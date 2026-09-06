import 'package:hive/hive.dart';
import '../models/customer_model.dart';
import '../models/product_model.dart';
import '../models/sale_model.dart';
import '../models/purchase_invoice_model.dart';
import '../models/purchase_item_model.dart';
import '../models/category_model.dart'; // 1. أضفنا الاستيراد هنا

class HiveBoxes {
  static Box<Customer> getCustomersBox() => Hive.box<Customer>('customersBox');
  static Box<Product> getProductsBox() => Hive.box<Product>('productsBox');
  static Box<SaleItem> getSalesBox() => Hive.box<SaleItem>('salesBox');
  static Box<PurchaseInvoice> getPurchaseInvoicesBox() => Hive.box<PurchaseInvoice>('purchaseInvoicesBox');
  static Box<PurchaseItem> getPurchaseItemsBox() => Hive.box<PurchaseItem>('purchaseItemsBox');
  static Box<CategoryModel> getCategoriesBox() => Hive.box<CategoryModel>('categoriesBox'); // 2. أضفنا الدالة هنا
}