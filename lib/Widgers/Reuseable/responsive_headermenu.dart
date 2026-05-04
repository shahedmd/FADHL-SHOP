import 'package:fadhl/Controllers/authcontroller.dart';
import 'package:fadhl/Controllers/cartcontroller.dart';
import 'package:fadhl/Controllers/productcontroller.dart';
import 'package:fadhl/Widgers/Reuseable/responsive_bottomnavbar.dart';
import 'package:fadhl/Widgers/Reuseable/reuseabledialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Admin Panel/Utils/global_colours.dart';

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
  const String phoneNumber = "880132540925";
  final Uri whatsappUrl = Uri.parse(
    "https://wa.me/$phoneNumber?text=${Uri.encodeComponent('Hello FADHL Support, I have a question regarding...')}",
  );
  try {
    await launchUrl(whatsappUrl, mode: LaunchMode.platformDefault);
  } catch (e) {
    Get.snackbar('Error', 'Could not open WhatsApp.');
  }
}

class CustomHeader extends StatefulWidget {
  const CustomHeader({super.key});

  @override
  State<CustomHeader> createState() => _CustomHeaderState();
}

class _CustomHeaderState extends State<CustomHeader> {
  final HeaderUIController uiController = Get.put(
    HeaderUIController(),
    permanent: true,
  );

  final MenuController contactMenuController = MenuController();
  final MenuController userMenuController = MenuController();

  bool isHoveringContactMenu = false;
  bool isHoveringUserMenu = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
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
            errorBuilder: (context, error, stackTrace) => const Text(
              'FADHL',
              style: TextStyle(
                color: AppColors.primaryGreen,
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
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: uiController.searchController,
                    onChanged: (value) => controller.updateSearch(value),
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textDark,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Search for premium products...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    width: 60,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.search,
                        color: AppColors.pureWhite,
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
            icon: Icons.local_shipping,
            text: 'Track Order',
            defaultColor: AppColors.textDark,
            hoverColor: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(width: 24),

        Obx(() {
          final bool isLoggedIn = authController.firebaseUser.value != null;
          final userData = authController.userData.value;

          if (isLoggedIn) {
            return _buildUserMenu(authController, userData);
          } else {
            return InkWell(
              onTap: () => Get.toNamed('/auth'),
              child: _HoverTextButton(
                icon: Icons.person_outline,
                text: 'Login',
                defaultColor: AppColors.textDark,
                hoverColor: AppColors.primaryGreen,
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
      controller: userMenuController,
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.pureWhite),
        elevation: WidgetStateProperty.all(12),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      builder: (context, controller, child) {
        return MouseRegion(
          onEnter: (_) {
            isHoveringUserMenu = true;
            if (!controller.isOpen) controller.open();
          },
          onExit: (_) async {
            isHoveringUserMenu = false;
            await Future.delayed(const Duration(milliseconds: 150));
            if (!isHoveringUserMenu && controller.isOpen) {
              controller.close();
            }
          },
          child: _HoverTextButton(
            icon: Icons.person,
            text: 'My Account',
            defaultColor: AppColors.textDark,
            hoverColor: AppColors.primaryGreen,
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
                onPressed: () => Get.toNamed('/profile'),
                child: _menuItemText(
                  Icons.assignment,
                  'My Orders',
                  AppColors.textDark,
                ),
              ),
              MenuItemButton(
                onPressed: () => Get.toNamed('/wishlist'),
                child: _menuItemText(
                  Icons.favorite,
                  'Wishlist',
                  Colors.pinkAccent,
                ),
              ),

              if (userData != null && userData['isAdmin'] == true) ...[
                const Divider(height: 1),
                MenuItemButton(
                  onPressed: () => Get.offAllNamed('/admin'),
                  child: _menuItemText(
                    Icons.build,
                    'Admin Panel',
                    AppColors.primaryGreen,
                  ),
                ),
              ],

              const Divider(height: 1),
              MenuItemButton(
                onPressed: () => authController.logout(),
                child: _menuItemText(
                  Icons.logout,
                  'Logout',
                  Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactMenu() {
    return MenuAnchor(
      controller: contactMenuController,
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.pureWhite),
        elevation: WidgetStateProperty.all(12),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      builder: (context, controller, child) {
        return MouseRegion(
          onEnter: (_) {
            isHoveringContactMenu = true;
            if (!controller.isOpen) controller.open();
          },
          onExit: (_) async {
            isHoveringContactMenu = false;
            await Future.delayed(const Duration(milliseconds: 150));
            if (!isHoveringContactMenu && controller.isOpen) {
              controller.close();
            }
          },
          child: _HoverTextButton(
            icon: Icons.headset_mic,
            text: 'Contact',
            defaultColor: AppColors.textDark,
            hoverColor: AppColors.primaryGreen,
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
                onPressed: () => Get.toNamed('/about'),
                child: _menuItemText(
                  Icons.info_outline,
                  'About Us',
                  AppColors.textDark,
                ),
              ),
              MenuItemButton(
                onPressed: () => makePhoneCall('88096977340925'),
                child: _menuItemText(
                  Icons.phone,
                  'Phone: +88096977340925',
                  AppColors.textDark,
                ),
              ),
              MenuItemButton(
                onPressed: _contactSupport,
                child: _menuItemText(
                  Icons.chat,
                  'WhatsApp',
                  Colors.green,
                ),
              ),
              MenuItemButton(
                onPressed: () => Get.toNamed('/faq'),
                child: _menuItemText(
                  Icons.help_outline,
                  'FAQs',
                  AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 2. MOBILE HEADER
  // ==========================================
  Widget _buildMobileHeader() {
    final ProductController controller = Get.find<ProductController>();

    return Obx(() {
      if (uiController.isMobileSearchActive.value) {
        return Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.primaryGreen,
                size: 20,
              ),
              onPressed: () => uiController.closeMobileSearch(controller),
            ),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: uiController.searchController,
                  onChanged: (value) => controller.updateSearch(value),
                  autofocus: true,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search products...',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(left: 16),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.close,
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
            icon: const Icon(
              Icons.sort,
              color: AppColors.textDark,
              size: 22,
            ),
            onPressed: () => _showIndependentMobileMenu(),
          ),

          InkWell(
            onTap: () => Get.toNamed('/'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo.webp',
                  height: 35,
                  cacheHeight: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
                const Text(
                  'FADHL SHOP',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.search,
                  color: AppColors.textDark,
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
            color: AppColors.pureWhite,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200, width: 1),
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
                      const Text(
                        'FADHL',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
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
                  final userData = authController.userData.value;

                  if (isLoggedIn) {
                    return Column(
                      children: [
                        _mobileMenuLink(
                          Icons.favorite,
                          'Wishlist',
                          () {
                            Get.back();
                            Get.toNamed('/wishlist');
                          },
                        ),
                        _mobileMenuLink(
                          Icons.assignment,
                          'My Orders',
                          () {
                            Get.back();
                            Get.toNamed('/profile');
                          },
                        ),
                        if (userData != null && userData['isAdmin'] == true)
                          _mobileMenuLink(
                            Icons.build,
                            'Admin Panel',
                            () {
                              Get.back();
                              Get.offAllNamed('/admin');
                            },
                          ),
                        _mobileMenuLink(
                          Icons.logout,
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
                      Icons.person_outline,
                      'Login / Register',
                      () {
                        Get.back();
                        Get.toNamed('/auth');
                      },
                    );
                  }
                }),
                Divider(color: Colors.grey.shade200, height: 30),
                _mobileMenuLink(Icons.local_shipping, 'Track Order', () {
                  Get.back();
                  showTrackOrderDialog();
                }),
                _mobileMenuLink(Icons.inventory_2, 'All Products', () {
                  Get.back();
                  Get.toNamed('/');
                }),
                Divider(color: Colors.grey.shade200, height: 30),
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
                  Icons.chat,
                  'WhatsApp Support',
                  () => _contactSupport(),
                  iconColor: Colors.green,
                ),
                _mobileMenuLink(
                  Icons.phone,
                  'Call Us',
                  () => makePhoneCall('+88096977340925'),
                ),
                _mobileMenuLink(Icons.info_outline, 'About Us', () {
                  Get.back();
                  Get.toNamed('/about');
                }),
                _mobileMenuLink(Icons.help_outline, 'FAQs', () {
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
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.primaryGreen,
        size: 18,
      ),
      title: Text(
        text,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 15,
        ),
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
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shopping_bag,
              color: AppColors.primaryGreen,
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
                border: Border.all(
                  color: AppColors.pureWhite,
                  width: 2,
                ),
              ),
              child: Obx(
                () => Text(
                  '${cartController.totalItems}',
                  style: const TextStyle(
                    color: AppColors.pureWhite,
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
          Icon(icon, size: 16, color: color),
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
// 4. ANIMATED HOVER BUTTON
// ==========================================
class _HoverTextButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color defaultColor;
  final Color hoverColor;
  final bool hasDropdown;

  _HoverTextButton({
    required this.icon,
    required this.text,
    required this.defaultColor,
    required this.hoverColor,
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
        final color = isHovered.value ? hoverColor : defaultColor;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: color, size: 16),
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
                Icon(Icons.keyboard_arrow_down, color: color, size: 16),
              ],
            ],
          ),
        );
      }),
    );
  }
}