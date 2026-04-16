import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Admin Panel/Utils/global_colours.dart';

Future<void> _launchSocialMedia(String url) async {
  if (url.isEmpty) return;
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    debugPrint('Could not launch $url');
  }
}

Future<void> sendEmail(String emailAddress) async {
  final Uri emailUri = Uri(scheme: 'mailto', path: emailAddress);

  try {
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      final Uri webMailUri = Uri.parse(
        'https://mail.google.com/mail/?view=cm&fs=1&to=$emailAddress',
      );
      if (await canLaunchUrl(webMailUri)) {
        await launchUrl(webMailUri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch email');
      }
    }
  } catch (e) {
    debugPrint('Error launching email: $e');
  }
}

Future<void> makePhoneCall(String phoneNumber) async {
  final String cleanNumber = phoneNumber.replaceAll(' ', '');
  final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);

  if (await canLaunchUrl(launchUri)) {
    await launchUrl(launchUri);
  } else {
    debugPrint('Could not launch $launchUri');
  }
}

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  // ==========================================
  // ROUTE MAPPINGS
  // ==========================================
  static const Map<String, String> infoLinks = {
    'About Us': '/about',
    'Login / Register': '/auth',
    'Terms & Conditions': '/terms', // Add route when built
    'Privacy Policy': '/policy', // Add route when built
  };

  static const Map<String, String> quickLinks = {
    'My Account': '/profile',
    'Shopping Cart': '/cart',
    'My Wishlist': '/wishlist',
    'All Products': '/',
  };

  static const Map<String, String> supportLinks = {
    'Order Tracking': '/track-order',
    'FAQ': '/faq',
    'How to Order': '/faq',
    'Support Center': '/about',
  };

  static const Map<String, String> policyLinks = {
    'Happy Return': '/policy',
    'Refund Policy': '/policy',
    'Exchange': '/policy',
    'Cancellation': '/policy',
  };

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: AppColors.textDark),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24.0 : 60.0,
        vertical: 70.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1250),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MAIN FOOTER CONTENT
              isMobile ? _buildMobileLayout() : _buildDesktopLayout(),

              const SizedBox(height: 60),

              // DIVIDER
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // BOTTOM STRIP (Copyright & Payments)
              isMobile ? _buildMobileBottomStrip() : _buildDesktopBottomStrip(),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // LAYOUTS
  // ==========================================

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(flex: 4, child: _buildBrandAndNewsletter()),
        const SizedBox(width: 60),
        Expanded(flex: 2, child: _buildLinkColumn('INFORMATION', infoLinks)),
        Expanded(flex: 2, child: _buildLinkColumn('QUICK LINKS', quickLinks)),
        Expanded(flex: 2, child: _buildLinkColumn('SUPPORT', supportLinks)),
        Expanded(flex: 2, child: _buildLinkColumn('POLICY', policyLinks)),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandAndNewsletter(),
        const SizedBox(height: 50),
        Wrap(
          spacing: 40,
          runSpacing: 40,
          children: [
            SizedBox(
              width: 140,
              child: _buildLinkColumn('INFORMATION', infoLinks),
            ),
            SizedBox(
              width: 140,
              child: _buildLinkColumn('QUICK LINKS', quickLinks),
            ),
            SizedBox(
              width: 140,
              child: _buildLinkColumn('SUPPORT', supportLinks),
            ),
            SizedBox(
              width: 140,
              child: _buildLinkColumn('POLICY', policyLinks),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // WIDGET COMPONENTS
  // ==========================================

  Widget _buildBrandAndNewsletter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo with White Circle Background
        Container(
          height: 130,
          width: 130,
          decoration: const BoxDecoration(
            color: AppColors.pureWhite,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Image.asset(
              'assets/logo.webp',
              fit: BoxFit.contain,
              errorBuilder:
                  (context, error, stackTrace) => const Text(
                    'FADHL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 12,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Description
        Text(
          'A premium e-commerce platform dedicated to providing safe, reliable, and luxury goods to every home.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
            height: 1.8,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 36),

        // NEWSLETTER BOX
        const Text(
          'SUBSCRIBE TO OUR NEWSLETTER',
          style: TextStyle(
            color: AppColors.pureWhite,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Enter your email address',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGold.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'SUBSCRIBE',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),

        // Contact Details
        _iconText(
          FontAwesomeIcons.locationDot,
          'Supermarket, Munshiganj Sadar-1500',
        ),
        const SizedBox(height: 16),
        _iconText(
          FontAwesomeIcons.phone,
          '+880 96997 340925',
          onTap: () => makePhoneCall('+88096997340925'),
        ),
        const SizedBox(height: 16),
        _iconText(
          FontAwesomeIcons.envelope,
          'fadhlshop013@gmail.com',
          onTap: () => sendEmail("fadhlshop013@gmail.com"),
        ),
        const SizedBox(height: 36),

        // Social Icons
        Row(
          children: [
            _HoverSocialIcon(
              icon: FontAwesomeIcons.facebookF,
              url: 'https://www.facebook.com/profile.php?id=61573352996622',
            ),
            _HoverSocialIcon(
              icon: FontAwesomeIcons.tiktok,
              url: 'https://www.tiktok.com/@fadhlshop',
            ),
            _HoverSocialIcon(
              icon: FontAwesomeIcons.instagram,
              url: 'https://www.instagram.com/fadhl_shop',
            ),
            _HoverSocialIcon(icon: FontAwesomeIcons.youtube, url: ''),
          ],
        ),
      ],
    );
  }

  Widget _iconText(IconData icon, String text, {VoidCallback? onTap}) {
    Widget content = Row(
      children: [
        FaIcon(icon, color: AppColors.primaryGold, size: 16),
        const SizedBox(width: 16),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: onTap, child: content),
      );
    }
    return content;
  }

  // UPDATED: Now accepts a Map to tie display text directly to GetX routes
  Widget _buildLinkColumn(String title, Map<String, String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.pureWhite,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        ...links.entries.map(
          (entry) => _HoverLink(text: entry.key, route: entry.value),
        ),
      ],
    );
  }

  Widget _buildDesktopBottomStrip() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '© 2026 FADHL. All Rights Reserved.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        Row(children: _buildPaymentIcons()),
      ],
    );
  }

  Widget _buildMobileBottomStrip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildPaymentIcons(),
        ),
        const SizedBox(height: 24),
        Text(
          '© 2026 FADHL. All Rights Reserved.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPaymentIcons() {
    return [
      FaIcon(
        FontAwesomeIcons.ccVisa,
        color: Colors.white.withValues(alpha: 0.4),
        size: 32,
      ),
      const SizedBox(width: 20),
      FaIcon(
        FontAwesomeIcons.ccMastercard,
        color: Colors.white.withValues(alpha: 0.4),
        size: 32,
      ),
      const SizedBox(width: 20),
      FaIcon(
        FontAwesomeIcons.ccAmex,
        color: Colors.white.withValues(alpha: 0.4),
        size: 32,
      ),
      const SizedBox(width: 20),
      FaIcon(
        FontAwesomeIcons.ccStripe,
        color: Colors.white.withValues(alpha: 0.4),
        size: 32,
      ),
    ];
  }
}

// ==========================================
// INTERACTIVE COMPONENTS (Refactored to GetX)
// ==========================================

class _HoverLink extends StatelessWidget {
  final String text;
  final String route; // ADDED Route property

  final RxBool _isHovered = false.obs;

  _HoverLink({required this.text, required this.route});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _isHovered.value = true,
      onExit: (_) => _isHovered.value = false,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // NAVIGATE TO ROUTE ON CLICK
          if (route.isNotEmpty) {
            Get.toNamed(route);
          }
        },
        child: Obx(
          () => AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            margin: EdgeInsets.only(
              bottom: 18.0,
              left: _isHovered.value ? 8.0 : 0.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isHovered.value) ...[
                  const FaIcon(
                    FontAwesomeIcons.angleRight,
                    color: AppColors.primaryGold,
                    size: 12,
                  ),
                  const SizedBox(width: 8),
                ],
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    color:
                        _isHovered.value
                            ? AppColors.primaryGold
                            : Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                    fontWeight:
                        _isHovered.value ? FontWeight.w600 : FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                  child: Text(text),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HoverSocialIcon extends StatelessWidget {
  final IconData icon;
  final String url;

  final RxBool _isHovered = false.obs;

  _HoverSocialIcon({required this.icon, required this.url});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _isHovered.value = true,
      onExit: (_) => _isHovered.value = false,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _launchSocialMedia(url),
        child: Obx(
          () => AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(right: 16),
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color:
                  _isHovered.value
                      ? AppColors.primaryGold
                      : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(
                icon,
                color:
                    _isHovered.value ? AppColors.textDark : AppColors.pureWhite,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}