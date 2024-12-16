import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/font_provider.dart';

class FontSettingsPage extends StatefulWidget {
  const FontSettingsPage({super.key});

  @override
  State<FontSettingsPage> createState() => _FontSettingsPageState();
}

class _FontSettingsPageState extends State<FontSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الخط'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Consumer<FontProvider>(
        builder: (context, fontProvider, child) {
          if (fontProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Directionality(
            textDirection: TextDirection.rtl,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'اختر حجم الخط المناسب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'معاينة حجم الخط',
                          style: TextStyle(
                            fontSize: 20 * fontProvider.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'هذا النص هو مثال لمعاينة حجم الخط. يمكنك تجربة أحجام مختلفة لاختيار ما يناسبك.',
                          style: TextStyle(
                            fontSize: 16 * fontProvider.fontSize,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'نص أصغر للمحتوى الثانوي',
                          style: TextStyle(
                            fontSize: 14 * fontProvider.fontSize,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('صغير'),
                    Text(
                      _getFontSizeLabel(fontProvider.fontSize),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('كبير'),
                  ],
                ),
                Slider(
                  value: fontProvider.fontSize,
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  label: _getFontSizeLabel(fontProvider.fontSize),
                  onChanged: (value) {
                    fontProvider.updateFontSize(value);
                  },
                ),
                const SizedBox(height: 32),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(height: 8),
                        Text(
                          'سيتم تطبيق التغييرات على جميع النصوص في التطبيق',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getFontSizeLabel(double scale) {
    if (scale <= 0.8) return 'صغير';
    if (scale <= 1.0) return 'متوسط';
    if (scale <= 1.2) return 'كبير';
    return 'كبير جداً';
  }
}
