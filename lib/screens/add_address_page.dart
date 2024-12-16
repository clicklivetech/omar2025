import 'package:flutter/material.dart';
import '../models/address.dart';

class AddAddressPage extends StatefulWidget {
  final Address? address;

  const AddAddressPage({
    super.key,
    this.address,
  });

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _buildingController = TextEditingController();
  final _floorController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _streetController.text = widget.address!.street;
      _cityController.text = widget.address!.city;
      _buildingController.text = widget.address!.building;
      _floorController.text = widget.address!.floor;
      _landmarkController.text = widget.address!.landmark;
      _phoneController.text = widget.address!.phone;
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _landmarkController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final newAddress = Address(
        id: widget.address?.id ?? DateTime.now().millisecondsSinceEpoch.toString(), // مؤقتاً نستخدم الوقت كمعرف
        street: _streetController.text,
        city: _cityController.text,
        building: _buildingController.text,
        floor: _floorController.text,
        landmark: _landmarkController.text,
        phone: _phoneController.text,
        isDefault: _isDefault,
      );

      // نرجع العنوان الجديد للصفحة السابقة
      Navigator.pop(context, newAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة عنوان جديد'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _streetController,
              decoration: const InputDecoration(
                labelText: 'الشارع',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم الشارع';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'المدينة',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم المدينة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _buildingController,
              decoration: const InputDecoration(
                labelText: 'رقم المبنى',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال رقم المبنى';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _floorController,
              decoration: const InputDecoration(
                labelText: 'الطابق',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال رقم الطابق';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _landmarkController,
              decoration: const InputDecoration(
                labelText: 'علامة مميزة',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال علامة مميزة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال رقم الهاتف';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _isDefault,
              onChanged: (value) {
                setState(() {
                  _isDefault = value ?? false;
                });
              },
              title: const Text('تعيين كعنوان افتراضي'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAddress,
                child: const Text('حفظ العنوان'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
