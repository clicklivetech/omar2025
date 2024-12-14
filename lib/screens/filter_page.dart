import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final List<String> _categories = ['الكل', 'خضروات', 'فواكه', 'توابل', 'مجمدات'];
  String _selectedCategory = 'الكل';
  RangeValues _priceRange = const RangeValues(0, 1000);
  bool _onlyAvailable = false;
  bool _onlyDiscount = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تصفية المنتجات'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'الفئات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _categories.map((category) {
                return FilterChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  selectedColor: const Color(0xFF7A14AD).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF7A14AD),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'نطاق السعر',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 1000,
              divisions: 20,
              activeColor: const Color(0xFF7A14AD),
              labels: RangeLabels(
                '${_priceRange.start.round()} ريال',
                '${_priceRange.end.round()} ريال',
              ),
              onChanged: (values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('المنتجات المتوفرة فقط'),
              value: _onlyAvailable,
              activeColor: const Color(0xFF7A14AD),
              onChanged: (value) {
                setState(() {
                  _onlyAvailable = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('العروض فقط'),
              value: _onlyDiscount,
              activeColor: const Color(0xFF7A14AD),
              onChanged: (value) {
                setState(() {
                  _onlyDiscount = value;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // تطبيق الفلتر
                Navigator.pop(context, {
                  'category': _selectedCategory,
                  'priceRange': _priceRange,
                  'onlyAvailable': _onlyAvailable,
                  'onlyDiscount': _onlyDiscount,
                });
              },
              child: const Text('تطبيق'),
            ),
          ],
        ),
      ),
    );
  }
}
