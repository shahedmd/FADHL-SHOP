// ignore_for_file: library_prefixes

import 'package:fadhl/Bindings/initial_binding.dart';
import 'package:fadhl/Middleware/admin_middleware.dart';
import 'package:fadhl/Middleware/auth_guard_middleware.dart';
import 'package:fadhl/Views/Pages/home.dart'; // ✅ Only home is eager
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'firebase_options.dart';

// ✅ All other pages are deferred (loaded only when user navigates there)
import 'package:fadhl/Admin%20Panel/Views/admin_dashboard_screen.dart'
    deferred as adminDashboard;
import 'package:fadhl/Views/Pages/cart_screen.dart' deferred as cart;
import 'package:fadhl/Views/Pages/faq_screen.dart' deferred as faq;
import 'package:fadhl/Views/Pages/ordertracking.dart' deferred as orderTracking;
import 'package:fadhl/Views/Pages/product_details_screen.dart' deferred as productDetails;
import 'package:fadhl/Views/Pages/profile_screen.dart' deferred as profile;
import 'package:fadhl/Views/Pages/wishlist_screen.dart' deferred as wishlist;
import 'package:fadhl/Views/Pages/about_us.dart' deferred as aboutUs;
import 'package:fadhl/Views/Pages/policy_view.dart' deferred as policy;
import 'package:fadhl/Views/Pages/term_view.dart' deferred as terms;
import 'Views/Pages/Auth/loginui.dart' deferred as auth;

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
        // ✅ Home loads instantly — no deferred needed
        GetPage(name: '/', page: () => const HomeScreen()),

        // ✅ Auth
        GetPage(
          name: '/auth',
          page:
              () => _DeferredPage(
                loader: auth.loadLibrary(),
                builder: () => auth.AuthScreen(),
              ),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 200),
        ),

        // ✅ Product Details
        GetPage(
          name: '/product/:id',
          page:
              () => _DeferredPage(
                loader: productDetails.loadLibrary(),
                builder: () => productDetails.ProductDetailsScreen(),
              ),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 200),
        ),

        // ✅ Cart
        GetPage(
          name: '/cart',
          page:
              () => _DeferredPage(
                loader: cart.loadLibrary(),
                builder: () => cart.CartScreen(),
              ),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 200),
        ),

        // ✅ Order Tracking
        GetPage(
          name: '/track-order',
          page:
              () => _DeferredPage(
                loader: orderTracking.loadLibrary(),
                builder: () => orderTracking.OrderTrackingScreen(),
              ),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 200),
        ),

        // ✅ Profile — protected
        GetPage(
          name: '/profile',
          page:
              () => _DeferredPage(
                loader: profile.loadLibrary(),
                builder: () => profile.ProfileScreen(),
              ),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 200),
          middlewares: [AuthGuard()],
        ),

        // ✅ Wishlist — protected
        GetPage(
          name: '/wishlist',
          page:
              () => _DeferredPage(
                loader: wishlist.loadLibrary(),
                builder: () => wishlist.WishlistScreen(),
              ),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 200),
          middlewares: [AuthGuard()],
        ),

        // ✅ About
        GetPage(
          name: '/about',
          page:
              () => _DeferredPage(
                loader: aboutUs.loadLibrary(),
                builder: () => aboutUs.AboutUsScreen(),
              ),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 200),
        ),

        // ✅ FAQ
        GetPage(
          name: '/faq',
          page:
              () => _DeferredPage(
                loader: faq.loadLibrary(),
                builder: () => faq.FaqScreen(),
              ),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 200),
        ),

        // ✅ Terms
        GetPage(
          name: '/terms',
          page:
              () => _DeferredPage(
                loader: terms.loadLibrary(),
                builder: () => terms.TermsScreen(),
              ),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 200),
        ),

        // ✅ Policy
        GetPage(
          name: '/policy',
          page:
              () => _DeferredPage(
                loader: policy.loadLibrary(),
                builder: () => policy.PolicyScreen(),
              ),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 200),
        ),

        // ✅ Admin — protected, deferred so users never download admin code
        GetPage(
          name: '/admin',
          page:
              () => _DeferredPage(
                loader: adminDashboard.loadLibrary(),
                builder: () => adminDashboard.AdminDashboardScreen(),
              ),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 200),
          middlewares: [AdminMiddleware()],
        ),
      ],
    );
  }
}

// ✅ Reusable deferred page loader widget
// Shows a small spinner while the page chunk downloads
class _DeferredPage extends StatefulWidget {
  final Future<void> loader;
  final Widget Function() builder;

  const _DeferredPage({required this.loader, required this.builder});

  @override
  State<_DeferredPage> createState() => _DeferredPageState();
}

class _DeferredPageState extends State<_DeferredPage> {
  late Future<void> _loader;

  @override
  void initState() {
    super.initState();
    _loader = widget.loader;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loader,
      builder: (context, snapshot) {
        // ✅ Page chunk loaded — show the page
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const _ErrorPage();
          }
          return widget.builder();
        }
        // ✅ Still loading chunk — show small spinner
        return const _PageLoader();
      },
    );
  }
}

// ✅ Small loading screen shown between page navigations
class _PageLoader extends StatelessWidget {
  const _PageLoader();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF0A1F13),
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}

// ✅ Error screen if a page chunk fails to load
class _ErrorPage extends StatelessWidget {
  const _ErrorPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: Color(0xFF0A1F13),
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load page',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0A1F13),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your connection and try again',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A1F13),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Get.offAllNamed('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}