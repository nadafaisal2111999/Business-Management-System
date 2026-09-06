import 'package:flutter/material.dart';

// عنصر مشترك (Widget) مخصص لحقول الإدخال عشان نوفر وقت وما نكرر الكود في كل شاشة
class CustomTextField extends StatelessWidget {
  final TextEditingController controller; // للتحكم في النص المدخل وقراءته
  final String label; // النص التوضيحي داخل الحقل (Label)
  final TextInputType keyboardType; // نوع لوحة المفاتيح
  final bool isNumeric; // متغير بسيط عشان نعرف لو الحقل أرقام بس

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.isNumeric = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // مسافة رأسية بين الحقول
      child: TextField(
        controller: controller, // ربط الحقل بالـ Controller الخاص بيه
        // لو مفعّل نخليه أرقام، ولو لا نخليه حسب النوع المحدد
        keyboardType: isNumeric ? TextInputType.number : keyboardType,
        decoration: InputDecoration(
          labelText: label, // عرض اسم الحقل
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // حواف دائرية شكلها شيك
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // مسافات داخلية
        ),
      ),
    );
  }
}