import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
import 'services/local_storage_service.dart';
import 'providers/font_provider.dart';
import 'screens/main_layout.dart';
import 'screens/login_page.dart';
import 'screens/category_products_page.dart';
import 'screens/splash_screen.dart';
import 'screens/cart_page.dart';
import 'screens/about_page.dart';
import 'screens/contact_page.dart';
import 'models/category.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  await LocalStorageService.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => FontProvider()..loadFontSettings(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final fontScale = context.watch<FontProvider>().fontSize;
    
    return MaterialApp(
      title: 'عمر ماركت',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[50],
        fontFamily: 'Cairo',
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Cairo', fontSize: 16 * fontScale),
          bodyMedium: TextStyle(fontFamily: 'Cairo', fontSize: 14 * fontScale),
          titleMedium: TextStyle(fontFamily: 'Cairo', fontSize: 16 * fontScale),
          titleLarge: TextStyle(fontFamily: 'Cairo', fontSize: 22 * fontScale),
          titleSmall: TextStyle(fontFamily: 'Cairo', fontSize: 14 * fontScale),
          bodySmall: TextStyle(fontFamily: 'Cairo', fontSize: 12 * fontScale),
        ),
      ),
      navigatorObservers: [RouteObserver<PageRoute>()],
      initialRoute: '/splash',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''),
      ],
      locale: const Locale('ar', ''),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const MainLayout(),
        '/login': (context) => const LoginPage(),
        '/cart_page': (context) => const CartPage(),
        '/about': (context) => const AboutPage(),
        '/contact': (context) => const ContactPage(),
        '/category': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final category = args['category'] as Category;
          return CategoryProductsPage(category: category);
        },
      },
      onGenerateRoute: (settings) {
        return null;
      },
    );
  }
}