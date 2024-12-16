import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  String _selectedTheme = 'light';
  bool _isLoading = true;
  bool _useSystemTheme = false;

  @override
  void initState() {
    super.initState();
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        final response = await SupabaseService.client
            .from('user_settings')
            .select('theme, use_system_theme')
            .eq('user_id', user.id)
            .single();
        
        setState(() {
          _selectedTheme = response['theme'] ?? 'light';
          _useSystemTheme = (response['use_system_theme'] ?? 'false').toLowerCase() == 'true';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveThemeSettings({
    String? theme,
    bool? useSystemTheme,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        final updates = {
          'user_id': user.id,
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (theme != null) {
          updates['theme'] = theme;
        }
        if (useSystemTheme != null) {
          updates['use_system_theme'] = useSystemTheme.toString();
        }

        await SupabaseService.client.from('user_settings').upsert(updates);

        setState(() {
          if (theme != null) _selectedTheme = theme;
          if (useSystemTheme != null) _useSystemTheme = useSystemTheme;
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
        title: const Text('إعدادات المظهر'),
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
                  _buildSystemThemeCard(),
                  if (!_useSystemTheme) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'اختر مظهر التطبيق',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildThemeCard(
                      theme: 'light',
                      title: 'الوضع الفاتح',
                      subtitle: 'مظهر فاتح مع خلفية بيضاء',
                      icon: Icons.light_mode,
                    ),
                    _buildThemeCard(
                      theme: 'dark',
                      title: 'الوضع المظلم',
                      subtitle: 'مظهر داكن يريح العين',
                      icon: Icons.dark_mode,
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(height: 8),
                          Text(
                            'سيتم تطبيق التغييرات فوراً',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSystemThemeCard() {
    return Card(
      child: SwitchListTile(
        title: const Text(
          'استخدام إعدادات النظام',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text(
          'تطبيق المظهر حسب إعدادات جهازك',
        ),
        value: _useSystemTheme,
        onChanged: (value) => _saveThemeSettings(useSystemTheme: value),
      ),
    );
  }

  Widget _buildThemeCard({
    required String theme,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedTheme == theme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => _saveThemeSettings(theme: theme),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
