import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/cart_provider.dart';
import 'screens/user/home_screen.dart';
import 'screens/user/splash_screen.dart';
import 'screens/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ShopNowApp());
}

class ShopNowApp extends StatelessWidget {
  const ShopNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        title: 'ShopNow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            primary: const Color(0xFF6C63FF),
            secondary: const Color(0xFFFF6584),
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFFF0F2FF),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (ctx) => const SplashScreen(),
          '/': (ctx) => const HomeScreen(),
          '/admin': (ctx) => const AdminDashboard(),
        },
      ),
    );
  }
}
//cd e:\shop_now\mysql_backend
//node index.js