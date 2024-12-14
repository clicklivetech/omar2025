import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/supabase_service.dart';
import 'services/local_storage_service.dart';
import 'screens/main_layout.dart';
import 'screens/login_page.dart';
import 'screens/category_products_page.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  await LocalStorageService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'عمر ماركت',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[50],
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
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/category') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => CategoryProductsPage(
              category: args['category'],
            ),
          );
        }
        return null;
      },
    );
  }
}