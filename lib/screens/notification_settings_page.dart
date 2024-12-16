import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _isLoading = true;
  bool _orderUpdates = true;
  bool _promotions = true;
  bool _appUpdates = true;
  bool _newProducts = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        final response = await SupabaseService.client
            .from('notification_settings')
            .select()
            .eq('user_id', user.id)
            .single();

        setState(() {
          _orderUpdates = response['order_updates'] ?? true;
          _promotions = response['promotions'] ?? true;
          _appUpdates = response['app_updates'] ?? true;
          _newProducts = response['new_products'] ?? true;
          _isLoading = false;
        });
      }
    } catch (e) {
      // If settings don't exist, create with defaults
      _saveSettings();
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        await SupabaseService.client.from('notification_settings').upsert({
          'user_id': user.id,
          'order_updates': _orderUpdates,
          'promotions': _promotions,
          'app_updates': _appUpdates,
          'new_products': _newProducts,
          'updated_at': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ الإعدادات بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ في حفظ الإعدادات'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الإشعارات'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'اختر الإشعارات التي تريد استلامها:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNotificationTile(
                    title: 'تحديثات الطلبات',
                    subtitle: 'إشعارات عن حالة طلباتك وتحديثاتها',
                    icon: Icons.local_shipping,
                    value: _orderUpdates,
                    onChanged: (value) {
                      setState(() {
                        _orderUpdates = value;
                      });
                      _saveSettings();
                    },
                  ),
                  _buildNotificationTile(
                    title: 'العروض والخصومات',
                    subtitle: 'إشعارات عن أحدث العروض والتخفيضات',
                    icon: Icons.local_offer,
                    value: _promotions,
                    onChanged: (value) {
                      setState(() {
                        _promotions = value;
                      });
                      _saveSettings();
                    },
                  ),
                  _buildNotificationTile(
                    title: 'تحديثات التطبيق',
                    subtitle: 'إشعارات عن تحديثات وتحسينات التطبيق',
                    icon: Icons.system_update,
                    value: _appUpdates,
                    onChanged: (value) {
                      setState(() {
                        _appUpdates = value;
                      });
                      _saveSettings();
                    },
                  ),
                  _buildNotificationTile(
                    title: 'المنتجات الجديدة',
                    subtitle: 'إشعارات عن المنتجات الجديدة المضافة',
                    icon: Icons.new_releases,
                    value: _newProducts,
                    onChanged: (value) {
                      setState(() {
                        _newProducts = value;
                      });
                      _saveSettings();
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'ملاحظة: يمكنك تغيير هذه الإعدادات في أي وقت من خلال هذه الصفحة.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        secondary: Icon(icon),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
