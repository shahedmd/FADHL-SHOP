import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../Admin Panel/Utils/global_colours.dart'; // Ensure AppColors is here

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      width: double.infinity,
      // Using a slightly deeper green overlay or pure primaryGreen
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
        // Optional: Add a subtle background pattern or gradient here if desired
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24.0 : 60.0,
        vertical: 60.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1250),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MAIN FOOTER CONTENT
              isMobile ? _buildMobileLayout() : _buildDesktopLayout(),

              const SizedBox(height: 50),

              // LUXURY GRADIENT DIVIDER
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGold.withValues(alpha: 0.05),
                      AppColors.primaryGold.withValues(alpha: 0.5),
                      AppColors.primaryGold.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
        // Col 1: Brand Info & Newsletter (Takes more space)
        Expanded(flex: 4, child: _buildBrandAndNewsletter()),
        const SizedBox(width: 40),

        // Col 2: Information
        Expanded(
          flex: 2,
          child: _buildLinkColumn('INFORMATION', [
            'About Us',
            'Contact Us',
            'Terms & Conditions',
            'Privacy Policy',
          ]),
        ),

        // Col 3: Shop By
        Expanded(
          flex: 2,
          child: _buildLinkColumn('SHOP BY', [
            'Eye Ware',
            'Organic Foods',
            'Pet Goods',
            'New Arrivals',
          ]),
        ),

        // Col 4: Support
        Expanded(
          flex: 2,
          child: _buildLinkColumn('SUPPORT', [
            'Support Center',
            'How to Order',
            'Order Tracking',
            'FAQ',
          ]),
        ),

        // Col 5: Consumer Policy
        Expanded(
          flex: 2,
          child: _buildLinkColumn('POLICY', [
            'Happy Return',
            'Refund Policy',
            'Exchange',
            'Cancellation',
          ]),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandAndNewsletter(),
        const SizedBox(height: 40),

        // Use a Wrap for mobile links to save vertical space
        Wrap(
          spacing: 40,
          runSpacing: 40,
          children: [
            SizedBox(
              width: 140,
              child: _buildLinkColumn('INFORMATION', [
                'About Us',
                'Contact Us',
                'Terms',
                'Privacy',
              ]),
            ),
            SizedBox(
              width: 140,
              child: _buildLinkColumn('SHOP BY', [
                'Eye Ware',
                'Organic',
                'Pet Goods',
                'New Arrivals',
              ]),
            ),
            SizedBox(
              width: 140,
              child: _buildLinkColumn('SUPPORT', [
                'Support Center',
                'How to Order',
                'Tracking',
                'FAQ',
              ]),
            ),
            SizedBox(
              width: 140,
              child: _buildLinkColumn('POLICY', [
                'Happy Return',
                'Refunds',
                'Exchange',
                'Cancellation',
              ]),
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
        // Logo
        Image.asset(
          'assets/logo.webp',
          height: 50,
          errorBuilder:
              (context, error, stackTrace) => const Text(
                'FADHL',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 32,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
        ),
        const SizedBox(height: 20),

        // Description
        const Text(
          'A premium e-commerce platform dedicated to providing safe, reliable, and luxury goods to every home.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.6,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 30),

        // Premium Newsletter Box
        const Text(
          'SUBSCRIBE TO OUR NEWSLETTER',
          style: TextStyle(
            color: AppColors.primaryGold,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.pureWhite.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Enter your email address',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGold,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(3),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'SUBSCRIBE',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // Contact Details
        _iconText(FontAwesomeIcons.locationDot, 'Rampura, Dhaka, Bangladesh'),
        const SizedBox(height: 12),
        _iconText(FontAwesomeIcons.phone, '+88 0123 456 789'),
        const SizedBox(height: 12),
        _iconText(FontAwesomeIcons.envelope, 'contact@fadhl.com'),
        const SizedBox(height: 30),

        // Social Icons
        Row(
          children: const [
            _HoverSocialIcon(icon: FontAwesomeIcons.facebookF),
            _HoverSocialIcon(icon: FontAwesomeIcons.twitter),
            _HoverSocialIcon(icon: FontAwesomeIcons.instagram),
            _HoverSocialIcon(icon: FontAwesomeIcons.youtube),
          ],
        ),
      ],
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      children: [
        FaIcon(icon, color: AppColors.primaryGold, size: 14),
        const SizedBox(width: 16),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildLinkColumn(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.pureWhite,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        ...links.map((link) => _HoverLink(text: link)),
      ],
    );
  }

  Widget _buildDesktopBottomStrip() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '© 2026 FADHL. All Rights Reserved.',
          style: TextStyle(
            color: Colors.white54,
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
        const SizedBox(height: 20),
        const Text(
          '© 2026 FADHL. All Rights Reserved.',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPaymentIcons() {
    return [
      const FaIcon(FontAwesomeIcons.ccVisa, color: Colors.white54, size: 28),
      const SizedBox(width: 16),
      const FaIcon(
        FontAwesomeIcons.ccMastercard,
        color: Colors.white54,
        size: 28,
      ),
      const SizedBox(width: 16),
      const FaIcon(FontAwesomeIcons.ccAmex, color: Colors.white54, size: 28),
      const SizedBox(width: 16),
      const FaIcon(FontAwesomeIcons.ccStripe, color: Colors.white54, size: 28),
    ];
  }
}

// ==========================================
// INTERACTIVE COMPONENTS (For Hover Effects)
// ==========================================

class _HoverLink extends StatefulWidget {
  final String text;
  const _HoverLink({required this.text});

  @override
  State<_HoverLink> createState() => _HoverLinkState();
}

class _HoverLinkState extends State<_HoverLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: () {},
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: _isHovered ? AppColors.primaryGold : Colors.white70,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
            child: Text(widget.text),
          ),
        ),
      ),
    );
  }
}

class _HoverSocialIcon extends StatefulWidget {
  final IconData icon;
  const _HoverSocialIcon({required this.icon});

  @override
  State<_HoverSocialIcon> createState() => _HoverSocialIconState();
}

class _HoverSocialIconState extends State<_HoverSocialIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.primaryGold : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryGold.withValues(
                alpha: _isHovered ? 1.0 : 0.4,
              ),
            ),
          ),
          child: FaIcon(
            widget.icon,
            color: _isHovered ? AppColors.textDark : AppColors.primaryGold,
            size: 16,
          ),
        ),
      ),
    );
  }
}
