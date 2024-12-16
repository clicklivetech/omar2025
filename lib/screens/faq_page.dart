import 'package:flutter/material.dart';
import 'contact_page.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأسئلة الشائعة'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildFAQSection(
              'التوصيل والطلبات',
              [
                {
                  'question': 'كم يستغرق توصيل الطلب؟',
                  'answer':
                      'نحن نقدم خدمة توصيل سريعة خلال 30-60 دقيقة داخل نطاق التوصيل. في أوقات الذروة قد يستغرق التوصيل حتى 90 دقيقة.',
                },
                {
                  'question': 'ما هي مناطق التوصيل المتاحة؟',
                  'answer':
                      'نقوم بالتوصيل لجميع المناطق في نطاق 10 كم من موقع المتجر. يمكنك التحقق من تغطية منطقتك عند إدخال العنوان.',
                },
                {
                  'question': 'هل يمكنني تتبع طلبي؟',
                  'answer':
                      'نعم، يمكنك تتبع طلبك مباشرة من التطبيق ومعرفة موقع المندوب في الوقت الفعلي.',
                },
              ],
            ),
            _buildFAQSection(
              'المنتجات والأسعار',
              [
                {
                  'question': 'هل الأسعار في التطبيق مطابقة لأسعار الفرع؟',
                  'answer': 'نعم، جميع الأسعار في التطبيق مطابقة لأسعار الفرع وتشمل ضريبة القيمة المضافة.',
                },
                {
                  'question': 'ماذا لو كان المنتج الذي أريده غير متوفر؟',
                  'answer':
                      'يمكنك اختيار "السماح بالبديل" عند الطلب، وسيقوم موظفونا باختيار بديل مناسب أو الاتصال بك للاستشارة.',
                },
                {
                  'question': 'هل يمكنني إرجاع المنتجات؟',
                  'answer':
                      'نعم، يمكنك إرجاع المنتجات غير المطابقة أو التالفة فور استلام الطلب. لا نقبل إرجاع المنتجات القابلة للتلف أو المجمدة.',
                },
              ],
            ),
            _buildFAQSection(
              'الدفع والحساب',
              [
                {
                  'question': 'ما هي طرق الدفع المتاحة؟',
                  'answer':
                      'نقبل الدفع بالبطاقات الائتمانية، مدى، ابل باي، والدفع عند الاستلام.',
                },
                {
                  'question': 'هل هناك حد أدنى للطلب؟',
                  'answer':
                      'نعم، الحد الأدنى للطلب هو 50 ريال للتوصيل المجاني. الطلبات الأقل من ذلك تخضع لرسوم توصيل إضافية.',
                },
                {
                  'question': 'كيف يمكنني الاستفادة من نقاط المكافآت؟',
                  'answer':
                      'تحصل على نقطة مقابل كل ريال تنفقه، ويمكنك استخدام النقاط في مشترياتك القادمة. كل 100 نقطة تعادل 1 ريال.',
                },
              ],
            ),
            _buildFAQSection(
              'العروض والخصومات',
              [
                {
                  'question': 'هل هناك عروض يومية؟',
                  'answer':
                      'نعم، نقدم عروضاً يومية على المنتجات الطازجة والأساسية. تجدها في قسم "عروض اليوم" في الصفحة الرئيسية.',
                },
                {
                  'question': 'هل يمكنني معرفة العروض الأسبوعية مقدماً؟',
                  'answer':
                      'نعم، يتم تحديث العروض الأسبوعية كل يوم سبت. فعّل الإشعارات لتصلك العروض الجديدة فور إضافتها.',
                },
                {
                  'question': 'كيف أستفيد من العروض الحصرية؟',
                  'answer':
                      'العملاء المميزون يحصلون على عروض حصرية. اشترك في برنامج الولاء للحصول على مزايا وعروض إضافية.',
                },
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'لم تجد إجابة لسؤالك؟',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactPage(),
                  ),
                );
              },
              child: const Text('تواصل مع الدعم'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection(String title, List<Map<String, String>> faqs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...faqs.map((faq) => _buildFAQItem(faq['question']!, faq['answer']!)),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: const TextStyle(
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
