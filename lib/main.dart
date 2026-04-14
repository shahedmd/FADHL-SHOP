import 'package:fadhl/Admin%20Panel/Views/admin_dashboard_screen.dart';
import 'package:fadhl/Middleware/admin_middleware.dart';
import 'package:fadhl/Middleware/auth_guard_middleware.dart';
import 'package:fadhl/Bindings/initial_binding.dart';
import 'package:fadhl/Views/Pages/cart_screen.dart';
import 'package:fadhl/Views/Pages/faq_screen.dart';
import 'package:fadhl/Views/Pages/home.dart';
import 'package:fadhl/Views/Pages/ordertracking.dart';
import 'package:fadhl/Views/Pages/product_details_screen.dart';
import 'package:fadhl/Views/Pages/profile_screen.dart';
import 'package:fadhl/Views/Pages/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Views/Pages/Auth/loginui.dart';
import 'Views/Pages/about_us.dart';
import 'firebase_options.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
 
void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FADHL E-Commerce',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0A1F13),
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      initialBinding: InitialBinding(),
      defaultTransition: Transition.noTransition,
      transitionDuration: Duration.zero,
      smartManagement: SmartManagement.keepFactory,

      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const HomeScreen()),
        GetPage(
          name: '/product/:id',
          page: () => ProductDetailsScreen(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/cart',
          page: () => CartScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/auth',
          page: () => AuthScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/track-order',
          page: () => OrderTrackingScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/profile',
          page: () => const ProfileScreen(),
          transition: Transition.fadeIn,
          middlewares: [AuthGuard()],
        ),
        // Inside your getPages array:
        GetPage(
          name: '/wishlist',
          page: () => WishlistScreen(),
          transition: Transition.fadeIn,
          middlewares: [AuthGuard()],
        ),
        GetPage(
          name: '/about',
          page: () => const AboutUsScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/faq',
          page: () => FaqScreen(),
          transition: Transition.fadeIn,
        ),

        GetPage(
          name: '/admin',
          page:
              () => AdminDashboardScreen(),
          middlewares: [AdminMiddleware()], 
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}
