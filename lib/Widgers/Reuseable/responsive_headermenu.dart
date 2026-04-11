import 'package:fadhl/Controllers/authcontroller.dart';
import 'package:fadhl/Controllers/cartcontroller.dart';
import 'package:fadhl/Controllers/productcontroller.dart';
import 'package:fadhl/Widgers/Reuseable/reuseabledialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// 🚀 1. GETX UI CONTROLLER (Only handles Search now)
class HeaderUIController extends GetxController {
  final RxBool isMobileSearchActive = false.obs;
  late final TextEditingController searchController;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void closeMobileSearch(ProductController productController) {
    isMobileSearchActive.value = false;
    searchController.clear();
    productController.updateSearch('');
  }
}

Future<void> _contactSupport() async {
  const String phoneNumber = "8801946401297";
  final Uri whatsappUrl = Uri.parse(
    "https://wa.me/$phoneNumber?text=${Uri.encodeComponent('Hello FADHL Support, I have a question regarding...')}",
  );
  try {
    await launchUrl(whatsappUrl, mode: LaunchMode.platformDefault);
  } catch (e) {
    Get.snackbar('Error', 'Could not open WhatsApp.');
  }
}

// 🚀 2. STATEFUL WIDGET (Fixes the MenuAnchor Crash!)
class CustomHeader extends StatefulWidget {
  const CustomHeader({super.key});

  @override
  State<CustomHeader> createState() => _CustomHeaderState();
}

class _CustomHeaderState extends State<CustomHeader> {
  final Color brandGreen = const Color(0xFF0A1F13);
  final Color brandGold = const Color(0xFFCEAB5F);

  // GetX Controller for Search (Still permanent)
  final HeaderUIController uiController = Get.put(
    HeaderUIController(),
    permanent: true,
  );

  // 🚀 THE FIX: Local UI Controllers bound safely to THIS specific header instance
  final MenuController contactMenuController = MenuController();
  final MenuController userMenuController = MenuController();

  // Safe hover state tracking
  bool isHoveringContactMenu = false;
  bool isHoveringUserMenu = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: brandGreen,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40.0 : 16.0,
        vertical: 16.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isDesktop ? _buildDesktopHeader() : _buildMobileHeader(),
        ),
      ),
    );
  }

  // ==========================================
  // 1. DESKTOP HEADER
  // ==========================================
  Widget _buildDesktopHeader() {
    final ProductController controller = Get.find<ProductController>();
    final AuthController authController = Get.find<AuthController>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () => Get.toNamed("/"),
          child: Image.asset(
            'assets/logo.webp',
            height: 100,
            cacheHeight: 240,
            fit: BoxFit.contain,
            errorBuilder:
                (context, error, stackTrace) => Text(
                  'FADHL',
                  style: TextStyle(
                    color: brandGold,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
        ),
        const SizedBox(width: 40),

        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: uiController.searchController,
                    onChanged: (value) => controller.updateSearch(value),
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Search for premium products...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    width: 60,
                    height: 48,
                    decoration: BoxDecoration(
                      color: brandGold,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.magnifyingGlass,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 40),

        _buildContactMenu(),
        const SizedBox(width: 24),
        InkWell(
          onTap: showTrackOrderDialog,
          child: _HoverTextButton(
            icon: FontAwesomeIcons.truckFast,
            text: 'Track Order',
            brandGold: brandGold,
          ),
        ),
        const SizedBox(width: 24),

        // DYNAMIC LOGIN / USER NAME
        Obx(() {
          final bool isLoggedIn = authController.firebaseUser.value != null;
          final userData = authController.userData.value; // 🚀 Track user data

          if (isLoggedIn) {
            return _buildUserMenu(
              authController,
              userData,
            ); // Pass userData here
          } else {
            return InkWell(
              onTap: () => Get.toNamed('/auth'),
              child: _HoverTextButton(
                icon: FontAwesomeIcons.user,
                text: 'Login',
                brandGold: brandGold,
              ),
            );
          }
        }),

        const SizedBox(width: 28),
        _buildCartIcon(),
      ],
    );
  }

  // ==========================================
  // DYNAMIC LOGGED-IN USER MENU
  // ==========================================
  Widget _buildUserMenu(
    AuthController authController,
    Map<String, dynamic>? userData,
  ) {
    return MenuAnchor(
      controller: userMenuController, // 🚀 Uses local state controller
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
        elevation: WidgetStateProperty.all(12),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      builder: (context, controller, child) {
        return MouseRegion(
          onEnter: (_) {
            isHoveringUserMenu = true;
            if (!controller.isOpen) controller.open(); // 🚀 Safe open check
          },
          onExit: (_) async {
            isHoveringUserMenu = false;
            await Future.delayed(const Duration(milliseconds: 150));
            if (!isHoveringUserMenu && controller.isOpen) {
              controller.close();
            }
          },
          child: _HoverTextButton(
            icon: FontAwesomeIcons.solidUser,
            text: 'My Account',
            brandGold: brandGold,
            hasDropdown: true,
          ),
        );
      },
      menuChildren: [
        MouseRegion(
          onEnter: (_) => isHoveringUserMenu = true,
          onExit: (_) async {
            isHoveringUserMenu = false;
            await Future.delayed(const Duration(milliseconds: 150));
            if (!isHoveringUserMenu && userMenuController.isOpen) {
              userMenuController.close();
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MenuItemButton(
                child: _menuItemText(
                  FontAwesomeIcons.clipboardList,
                  'My Orders',
                  Colors.black87,
                ),
                onPressed: () => Get.toNamed('/profile'),
              ),
              MenuItemButton(
                child: _menuItemText(
                  FontAwesomeIcons.solidHeart,
                  'Wishlist',
                  Colors.pinkAccent,
                ),
                onPressed: () => Get.toNamed('/wishlist'),
              ),

              // 🚀 THE BRIDGE (Website -> Admin Panel)
              if (userData != null && userData['isAdmin'] == true) ...[
                const Divider(height: 1),
                MenuItemButton(
                  child: _menuItemText(
                    FontAwesomeIcons.screwdriverWrench,
                    'Admin Panel',
                    brandGold,
                  ),
                  onPressed:
                      () => Get.offAllNamed('/admin'), // Routes back to admin!
                ),
              ],

              const Divider(height: 1),
              MenuItemButton(
                child: _menuItemText(
                  FontAwesomeIcons.arrowRightFromBracket,
                  'Logout',
                  Colors.redAccent,
                ),
                onPressed: () => authController.logout(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactMenu() {
    return MenuAnchor(
      controller: contactMenuController, // 🚀 Uses local state controller
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
        elevation: WidgetStateProperty.all(12),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      builder: (context, controller, child) {
        return MouseRegion(
          onEnter: (_) {
            isHoveringContactMenu = true;
            if (!controller.isOpen) controller.open(); // 🚀 Safe open check
          },
          onExit: (_) async {
            isHoveringContactMenu = false;
            await Future.delayed(const Duration(milliseconds: 150));
            if (!isHoveringContactMenu && controller.isOpen) {
              controller.close();
            }
          },
          child: _HoverTextButton(
            icon: FontAwesomeIcons.headset,
            text: 'Contact',
            brandGold: brandGold,
            hasDropdown: true,
          ),
        );
      },
      menuChildren: [
        MouseRegion(
          onEnter: (_) => isHoveringContactMenu = true,
          onExit: (_) async {
            isHoveringContactMenu = false;
            await Future.delayed(const Duration(milliseconds: 150));
            if (!isHoveringContactMenu && contactMenuController.isOpen) {
              contactMenuController.close();
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MenuItemButton(
                child: _menuItemText(
                  FontAwesomeIcons.circleInfo,
                  'About Us',
                  Colors.black87,
                ),
                onPressed: () => Get.toNamed('/about'),
              ),
              MenuItemButton(
                child: _menuItemText(
                  FontAwesomeIcons.phone,
                  'Phone: +880 1946 401297',
                  Colors.black87,
                ),
                onPressed: () {},
              ),
              MenuItemButton(
                onPressed: _contactSupport,
                child: _menuItemText(
                  FontAwesomeIcons.whatsapp,
                  'WhatsApp',
                  Colors.green,
                ),
              ),
              MenuItemButton(
                child: _menuItemText(
                  FontAwesomeIcons.circleQuestion,
                  'FAQs',
                  Colors.black87,
                ),
                onPressed: () => Get.toNamed('/faq'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 2. MOBILE HEADER & HELPERS (Unchanged functionality)
  // ==========================================
  Widget _buildMobileHeader() {
    final ProductController controller = Get.find<ProductController>();

    return Obx(() {
      if (uiController.isMobileSearchActive.value) {
        return Row(
          children: [
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.arrowLeft,
                color: brandGold,
                size: 20,
              ),
              onPressed: () => uiController.closeMobileSearch(controller),
            ),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: uiController.searchController,
                  onChanged: (value) => controller.updateSearch(value),
                  autofocus: true,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search products...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(left: 16),
                    suffixIcon: IconButton(
                      icon: const FaIcon(
                        FontAwesomeIcons.xmark,
                        color: Colors.grey,
                        size: 16,
                      ),
                      onPressed: () {
                        uiController.searchController.clear();
                        controller.updateSearch('');
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.barsStaggered,
              color: brandGold,
              size: 22,
            ),
            onPressed: () => _showIndependentMobileMenu(),
          ),
          InkWell(
            onTap: () => Get.toNamed('/'),
            child: Image.asset(
              'assets/logo.webp',
              height: 70,
              cacheHeight: 240,
              fit: BoxFit.contain,
              errorBuilder:
                  (c, e, s) => Text(
                    'FADHL',
                    style: TextStyle(
                      color: brandGold,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.magnifyingGlass,
                  color: brandGold,
                  size: 20,
                ),
                onPressed: () => uiController.isMobileSearchActive.value = true,
              ),
              const SizedBox(width: 8),
              _buildCartIcon(),
            ],
          ),
        ],
      );
    });
  }

  void _showIndependentMobileMenu() {
    final AuthController authController = Get.find<AuthController>();

    Get.dialog(
      Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 280,
            height: double.infinity,
            color: brandGreen,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFF07140C),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFCEAB5F), width: 1),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Get.back();
                          Get.toNamed('/');
                        },
                        child: Image.asset(
                          'assets/logo.webp',
                          height: 60,
                          cacheHeight: 240,
                          errorBuilder: (c, e, s) => const SizedBox(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'FADHL',
                        style: TextStyle(
                          color: brandGold,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() {
                  final bool isLoggedIn =
                      authController.firebaseUser.value != null;
                  final userData =
                      authController.userData.value; // 🚀 Track user data

                  if (isLoggedIn) {
                    return Column(
                      children: [
                        _mobileMenuLink(
                          FontAwesomeIcons.solidHeart,
                          'Wishlist',
                          () {
                            Get.back();
                            Get.toNamed('/wishlist');
                          },
                        ),
                        _mobileMenuLink(
                          FontAwesomeIcons.clipboardList,
                          'My Orders',
                          () {
                            Get.back();
                            Get.toNamed('/profile');
                          },
                        ),

                        // 🚀 THE BRIDGE (Website -> Admin Panel) - Mobile
                        if (userData != null && userData['isAdmin'] == true)
                          _mobileMenuLink(
                            FontAwesomeIcons.screwdriverWrench,
                            'Admin Panel',
                            () {
                              Get.back();
                              Get.offAllNamed('/admin');
                            },
                            iconColor: brandGold,
                          ),

                        _mobileMenuLink(
                          FontAwesomeIcons.arrowRightFromBracket,
                          'Logout',
                          () {
                            Get.back();
                            authController.logout();
                          },
                          iconColor: Colors.redAccent,
                        ),
                      ],
                    );
                  } else {
                    return _mobileMenuLink(
                      FontAwesomeIcons.user,
                      'Login / Register',
                      () {
                        Get.back();
                        Get.toNamed('/auth');
                      },
                    );
                  }
                }),
                const Divider(color: Colors.white24, height: 30),
                _mobileMenuLink(FontAwesomeIcons.truckFast, 'Track Order', () {
                  Get.back();
                  showTrackOrderDialog();
                }),
                _mobileMenuLink(FontAwesomeIcons.boxOpen, 'All Products', () {
                  Get.back();
                  Get.toNamed('/');
                }),
                const Divider(color: Colors.white24, height: 30),
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 10, top: 10),
                  child: Text(
                    'CONTACT US',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _mobileMenuLink(
                  FontAwesomeIcons.whatsapp,
                  'WhatsApp Support',
                  () => _contactSupport(),
                  iconColor: Colors.green,
                ),
                _mobileMenuLink(
                  FontAwesomeIcons.phone,
                  'Call Us',
                  () => Get.back(),
                ),
                _mobileMenuLink(FontAwesomeIcons.circleInfo, 'About Us', () {
                  Get.back();
                  Get.toNamed('/about');
                }),
                _mobileMenuLink(FontAwesomeIcons.circleQuestion, 'FAQS', () {
                  Get.toNamed('/faq');
                }),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionCurve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  Widget _mobileMenuLink(
    IconData icon,
    String text,
    VoidCallback onTap, {
    Color? iconColor,
  }) {
    return ListTile(
      leading: FaIcon(icon, color: iconColor ?? brandGold, size: 18),
      title: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      onTap: onTap,
    );
  }

  Widget _buildCartIcon() {
    final CartController cartController = Get.find<CartController>();

    return InkWell(
      onTap: () => Get.toNamed('/cart'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: brandGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FaIcon(
              FontAwesomeIcons.bagShopping,
              color: brandGold,
              size: 20,
            ),
          ),
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                border: Border.all(color: brandGreen, width: 2),
              ),
              child: Obx(
                () => Text(
                  '${cartController.totalItems}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItemText(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          FaIcon(icon, size: 16, color: color),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🚀 4. GETX ANIMATED HOVER BUTTON (Stateless is fine here)
// ==========================================
class _HoverTextButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color brandGold;
  final bool hasDropdown;

  _HoverTextButton({
    required this.icon,
    required this.text,
    required this.brandGold,
    this.hasDropdown = false,
  });

  final RxBool isHovered = false.obs;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: Obx(() {
        final color = isHovered.value ? brandGold : Colors.white;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              FaIcon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
              if (hasDropdown) ...[
                const SizedBox(width: 6),
                FaIcon(FontAwesomeIcons.chevronDown, color: color, size: 12),
              ],
            ],
          ),
        );
      }),
    );
  }
}
