import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'login_page.dart';
import 'edit_profile_page.dart';
import 'current_orders_page.dart';
import 'previous_orders_page.dart';
import 'notification_settings_page.dart';
import 'language_settings_page.dart';
import 'theme_settings_page.dart';
import 'font_settings_page.dart';
import 'faq_page.dart';
import 'privacy_policy_page.dart';
import 'about_page.dart';
import 'contact_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    setState(() {
      _isLoading = true;
    });
    
    final user = SupabaseService.client.auth.currentUser;
    if (user != null) {
      try {
        final response = await SupabaseService.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        
        if (mounted) {
          setState(() {
            _isLoggedIn = true;
            _userProfile = response;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoggedIn = true;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('حدث خطأ في تحميل بيانات المستخدم'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        final response = await SupabaseService.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        setState(() {
          _userProfile = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ في تحميل بيانات المستخدم'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await SupabaseService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء تسجيل الخروج'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildGuestView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Icon(
            Icons.account_circle,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            'مرحباً بك في متجرنا',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'سجل دخول للوصول إلى جميع المميزات',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
              if (result == true) {
                if (mounted) {
                  _checkLoginStatus();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child: const Text('تسجيل الدخول'),
          ),
          const SizedBox(height: 40),
          const Divider(),
          
          // الإعدادات العامة للزوار
          ExpansionTile(
            leading: const Icon(Icons.settings),
            title: const Text('الإعدادات'),
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('اللغة'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LanguageSettingsPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('المظهر'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ThemeSettingsPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.font_download),
                title: const Text('حجم الخط'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FontSettingsPage()),
                  );
                },
              ),
            ],
          ),
          
          // المعلومات والمساعدة للزوار
          ExpansionTile(
            leading: const Icon(Icons.help),
            title: const Text('المساعدة والدعم'),
            children: [
              ListTile(
                leading: const Icon(Icons.question_answer),
                title: const Text('الأسئلة الشائعة'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FAQPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('سياسة الخصوصية'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('عن التطبيق'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.contact_support),
                title: const Text('اتصل بنا'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ContactPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // معلومات الملف الشخصي
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _userProfile?['avatar_url'] != null
                      ? NetworkImage(_userProfile!['avatar_url'])
                      : null,
                  child: _userProfile?['avatar_url'] == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 18),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        );
                        if (result == true) {
                          _loadUserProfile();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _userProfile?['name'] ?? 'المستخدم',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            _userProfile?['email'] ?? '',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          const Divider(),
          
          // إدارة الحساب
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('تعديل الملف الشخصي'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfilePage()),
              ).then((value) {
                if (value == true) {
                  _loadUserProfile();
                }
              });
            },
          ),
          
          // إدارة الطلبات
          ExpansionTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('طلباتي'),
            children: [
              ListTile(
                leading: const Icon(Icons.local_shipping),
                title: const Text('الطلبات الحالية'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CurrentOrdersPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('الطلبات السابقة'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PreviousOrdersPage()),
                  );
                },
              ),
            ],
          ),
          
          // الإشعارات
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('إعدادات الإشعارات'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationSettingsPage()),
              );
            },
          ),
          
          // الإعدادات العامة
          ExpansionTile(
            leading: const Icon(Icons.settings),
            title: const Text('الإعدادات'),
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('اللغة'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LanguageSettingsPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('المظهر'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ThemeSettingsPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.font_download),
                title: const Text('حجم الخط'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FontSettingsPage()),
                  );
                },
              ),
            ],
          ),
          
          // المعلومات والمساعدة
          ExpansionTile(
            leading: const Icon(Icons.help),
            title: const Text('المساعدة والدعم'),
            children: [
              ListTile(
                leading: const Icon(Icons.question_answer),
                title: const Text('الأسئلة الشائعة'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FAQPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('سياسة الخصوصية'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('عن التطبيق'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.contact_support),
                title: const Text('اتصل بنا'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ContactPage()),
                  );
                },
              ),
            ],
          ),
          
          const Divider(),
          // زر تسجيل الخروج
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _isLoggedIn
                ? _buildLoggedInView()
                : _buildGuestView(),
      ),
    );
  }
}
