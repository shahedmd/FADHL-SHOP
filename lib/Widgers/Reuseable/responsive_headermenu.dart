import 'package:fadhl/Controllers/authcontroller.dart';
import 'package:fadhl/Controllers/cartcontroller.dart';
import 'package:fadhl/Controllers/productcontroller.dart';
import 'package:fadhl/Widgers/Reuseable/responsive_bottomnavbar.dart';
import 'package:fadhl/Widgers/Reuseable/reuseabledialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
            color: Colors.black.withValues(
              alpha: 0.05,
            ), // Softer shadow for white bg
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
            errorBuilder:
                (context, error, stackTrace) => const Text(
                  'FADHL',
                  style: TextStyle(
                    color: AppColors.primaryGreen, // Contrast against white bg
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
              color:
                  AppColors.backgroundLight, // Slightly off-white for contrast
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade300,
              ), // Added border to frame it
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
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen, // Green search button
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.magnifyingGlass,
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
            icon: FontAwesomeIcons.truckFast,
            text: 'Track Order',
            defaultColor: AppColors.textDark, // Dark text on white bg
            hoverColor: AppColors.primaryGreen, // Hover turns green
          ),
        ),
        const SizedBox(width: 24),

        // DYNAMIC LOGIN / USER NAME
        Obx(() {
          final bool isLoggedIn = authController.firebaseUser.value != null;
          final userData = authController.userData.value;

          if (isLoggedIn) {
            return _buildUserMenu(authController, userData);
          } else {
            return InkWell(
              onTap: () => Get.toNamed('/auth'),
              child: _HoverTextButton(
                icon: FontAwesomeIcons.user,
                text: 'Login',
                defaultColor: AppColors.textDark, // Dark text on white bg
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
            icon: FontAwesomeIcons.solidUser,
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
                child: _menuItemText(
                  FontAwesomeIcons.clipboardList,
                  'My Orders',
                  AppColors.textDark,
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

              if (userData != null && userData['isAdmin'] == true) ...[
                const Divider(height: 1),
                MenuItemButton(
                  child: _menuItemText(
                    FontAwesomeIcons.screwdriverWrench,
                    'Admin Panel',
                    AppColors.primaryGreen, // Updated
                  ),
                  onPressed: () => Get.offAllNamed('/admin'),
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
            icon: FontAwesomeIcons.headset,
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
                child: _menuItemText(
                  FontAwesomeIcons.circleInfo,
                  'About Us',
                  AppColors.textDark,
                ),
                onPressed: () => Get.toNamed('/about'),
              ),
              MenuItemButton(
                child: _menuItemText(
                  FontAwesomeIcons.phone,
                  'Phone: +88096977340925',
                  AppColors.textDark,
                ),
                onPressed: () {
                  makePhoneCall('88096977340925');
                },
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
                  AppColors.textDark,
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
  // 2. MOBILE HEADER
  // ==========================================
  Widget _buildMobileHeader() {
    final ProductController controller = Get.find<ProductController>();

    return Obx(() {
      if (uiController.isMobileSearchActive.value) {
        return Row(
          children: [
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.arrowLeft,
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
            icon: const FaIcon(
              FontAwesomeIcons.barsStaggered,
              color: AppColors.textDark,
              size: 22,
            ),
            onPressed: () => _showIndependentMobileMenu(),
          ),

          // 🚀 UPDATED: Logo and Company Name side-by-side
          InkWell(
            onTap: () => Get.toNamed('/'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo.webp',
                  height: 35, // Reduced slightly to fit well inline with text
                  cacheHeight: 120,
                  fit: BoxFit.contain,
                  // If the image fails to load, the Text beside it still shows the brand name
                  errorBuilder: (c, e, s) => const SizedBox.shrink(),
                ),
                const SizedBox(width: 8), // Spacing between logo and text
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
                icon: const FaIcon(
                  FontAwesomeIcons.magnifyingGlass,
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
            color: AppColors.pureWhite, // 🚀 Fully clean light theme drawer!
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
                          color: AppColors.primaryGreen, // Updated
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
                        if (userData != null && userData['isAdmin'] == true)
                          _mobileMenuLink(
                            FontAwesomeIcons.screwdriverWrench,
                            'Admin Panel',
                            () {
                              Get.back();
                              Get.offAllNamed('/admin');
                            },
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
                Divider(color: Colors.grey.shade200, height: 30),
                _mobileMenuLink(FontAwesomeIcons.truckFast, 'Track Order', () {
                  Get.back();
                  showTrackOrderDialog();
                }),
                _mobileMenuLink(FontAwesomeIcons.boxOpen, 'All Products', () {
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
                  FontAwesomeIcons.whatsapp,
                  'WhatsApp Support',
                  () => _contactSupport(),
                  iconColor: Colors.green,
                ),
                _mobileMenuLink(
                  FontAwesomeIcons.phone,
                  'Call Us',
                  () => makePhoneCall('+88096977340925'),
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
      leading: FaIcon(
        icon,
        color: iconColor ?? AppColors.primaryGreen, // Default to green
        size: 18,
      ),
      title: Text(
        text,
        style: const TextStyle(
          color: AppColors.textDark, // Dark text on white bg
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
              color: AppColors.primaryGreen.withValues(alpha: 0.1), // Updated
              borderRadius: BorderRadius.circular(8),
            ),
            child: const FaIcon(
              FontAwesomeIcons.bagShopping,
              color: AppColors.primaryGreen, // Updated
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
                  color: AppColors.pureWhite, // Matched to white header bg
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
  final Color defaultColor; // Added default state color
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
        final color =
            isHovered.value ? hoverColor : defaultColor; // Uses passed colors

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
