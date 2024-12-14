# متجر عمر - دليل المطور

## نظرة عامة
متجر عمر هو تطبيق للتجارة الإلكترونية مبني باستخدام Flutter وSupabase. يوفر التطبيق واجهة سهلة الاستخدام لتصفح وشراء المنتجات مع نظام مصادقة متكامل.

## هيكل المشروع

```
lib/
├── main.dart                 # نقطة البداية للتطبيق
├── models/                   # نماذج البيانات
│   └── category.dart         # نموذج الفئات
├── screens/                  # شاشات التطبيق
│   ├── home_layout.dart      # التخطيط الرئيسي
│   ├── home_page.dart        # الصفحة الرئيسية
│   ├── login_page.dart       # صفحة تسجيل الدخول
│   ├── register_page.dart    # صفحة إنشاء حساب
│   ├── filter_page.dart      # صفحة تصفية المنتجات
│   └── profile_page.dart     # صفحة الملف الشخصي
└── services/                 # الخدمات
    └── supabase_service.dart # خدمات Supabase
```

## هوية التطبيق
- اللون الأساسي: `#7A14AD` (بنفسجي غامق)
- اللون الثانوي: `#6CC0B8` (تركواز)

## قاعدة البيانات (Supabase)

### جداول قاعدة البيانات:

1. **جدول المستخدمين (auth.users)**
   - يدار تلقائياً بواسطة Supabase
   - يحتوي على معلومات المصادقة الأساسية

2. **جدول الملفات الشخصية (profiles)**
   ```sql
   id: uuid (المفتاح الأساسي)
   name: text
   email: text
   created_at: timestamp
   ```

3. **جدول الفئات (categories)**
   ```sql
   id: bigint
   name: text
   description: text
   image_url: text
   is_home: boolean
   created_at: timestamp
   updated_at: timestamp
   ```

## مسارات العمل الرئيسية

### 1. المصادقة
- **تسجيل الدخول**: `lib/screens/login_page.dart`
  ```dart
  SupabaseService.signIn(email: string, password: string)
  ```
- **إنشاء حساب**: `lib/screens/register_page.dart`
  ```dart
  SupabaseService.signUp(email: string, password: string, name: string)
  ```

### 2. الصفحة الرئيسية
- **عرض الفئات**: `lib/screens/home_page.dart`
  ```dart
  SupabaseService.getHomeCategories()
  ```

### 3. تصفية المنتجات
- **فلترة حسب**: `lib/screens/filter_page.dart`
  - الفئة
  - نطاق السعر
  - التوفر
  - العروض

## كيفية التعديل

### 1. إضافة صفحة جديدة
1. أنشئ ملف جديد في مجلد `lib/screens/`
2. قم بإضافة الصفحة إلى نظام التنقل في `home_layout.dart`

### 2. تعديل الألوان
- قم بتحديث الألوان في `lib/main.dart`:
  ```dart
  static const primaryColor = Color(0xFF7A14AD);
  static const secondaryColor = Color(0xFF6CC0B8);
  ```

### 3. إضافة نموذج جديد
1. أنشئ ملف جديد في مجلد `lib/models/`
2. قم بتنفيذ `fromJson` و `toJson` للتعامل مع البيانات

### 4. إضافة خدمة جديدة
1. أضف الدالة الجديدة في `lib/services/supabase_service.dart`
2. اتبع نمط معالجة الأخطاء الموجود

## أفضل الممارسات
1. استخدم التعليقات باللغة العربية للتوثيق
2. اتبع نمط التسمية المتناسق
3. تأكد من معالجة جميع حالات الخطأ
4. استخدم `mounted` للتحقق قبل تحديث state
5. اجعل واجهة المستخدم متجاوبة مع جميع أحجام الشاشات

## الأمان
1. لا تقم بتخزين البيانات الحساسة في التطبيق
2. استخدم RLS (Row Level Security) في Supabase
3. تحقق من صحة المدخلات دائماً
4. استخدم HTTPS للاتصالات

## التحديثات المستقبلية المقترحة
1. إضافة نظام السلة
2. إدارة المنتجات
3. نظام الدفع
4. إشعارات المستخدم
5. تتبع الطلبات
