import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سياسة الخصوصية'),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'سياسة الخصوصية',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'آخر تحديث: ${DateTime.now().toString().split(' ')[0]}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'مقدمة',
              'نحن نقدر خصوصيتك ونلتزم بحماية بياناتك الشخصية. توضح سياسة الخصوصية هذه كيفية جمع واستخدام وحماية معلوماتك الشخصية عند استخدام تطبيقنا.',
            ),
            _buildSection(
              'المعلومات التي نجمعها',
              '''نحن نجمع المعلومات التالية:
• معلومات الحساب (الاسم، البريد الإلكتروني، رقم الهاتف)
• معلومات الدفع
• عنوان التوصيل
• سجل الطلبات والمشتريات
• معلومات الجهاز وبيانات الاستخدام''',
            ),
            _buildSection(
              'كيف نستخدم معلوماتك',
              '''نستخدم معلوماتك للأغراض التالية:
• معالجة وتوصيل طلباتك
• إدارة حسابك
• تحسين خدماتنا
• التواصل معك بخصوص الطلبات والعروض
• حماية أمن وسلامة خدماتنا''',
            ),
            _buildSection(
              'حماية المعلومات',
              'نحن نتخذ إجراءات أمنية مناسبة لحماية معلوماتك من الوصول غير المصرح به أو التغيير أو الإفصاح أو الإتلاف.',
            ),
            _buildSection(
              'مشاركة المعلومات',
              '''نشارك معلوماتك فقط في الحالات التالية:
• مع مقدمي الخدمات المعتمدين (مثل خدمات الدفع والتوصيل)
• عند الضرورة للامتثال للقانون
• لحماية حقوقنا أو ممتلكاتنا''',
            ),
            _buildSection(
              'حقوقك',
              '''لديك الحق في:
• الوصول إلى معلوماتك الشخصية
• تصحيح معلوماتك
• حذف حسابك
• الاعتراض على معالجة بياناتك
• سحب موافقتك في أي وقت''',
            ),
            _buildSection(
              'ملفات تعريف الارتباط',
              'نستخدم ملفات تعريف الارتباط وتقنيات مماثلة لتحسين تجربة المستخدم وتحليل كيفية استخدام خدماتنا.',
            ),
            _buildSection(
              'التغييرات في سياسة الخصوصية',
              'قد نقوم بتحديث سياسة الخصوصية من وقت لآخر. سنخطرك بأي تغييرات جوهرية من خلال إشعار في التطبيق.',
            ),
            _buildSection(
              'اتصل بنا',
              'إذا كان لديك أي أسئلة حول سياسة الخصوصية، يرجى التواصل معنا.',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/contact');
              },
              child: const Text('تواصل معنا'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              height: 1.5,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
