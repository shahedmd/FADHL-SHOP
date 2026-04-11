import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  final Color brandGreen = const Color(0xFF0A1F13);
  final Color brandGold = const Color(0xFFCEAB5F);

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      width: double.infinity,
      color: brandGreen, // Premium Dark Green Background
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20.0 : 40.0,
        vertical: 40.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MAIN FOOTER CONTENT (Responsive)
              isMobile ? _buildMobileLayout() : _buildDesktopLayout(),

              const SizedBox(height: 40),
              Divider(color: brandGold.withValues(alpha:  0.3), thickness: 1),
              const SizedBox(height: 20),

              // BOTTOM STRIP (Copyright & Payments)
              isMobile ? _buildMobileBottomStrip() : _buildDesktopBottomStrip(),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // DESKTOP LAYOUT (5 Columns)
  // ==========================================
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Col 1: Brand Info
        Expanded(flex: 3, child: _buildBrandInfo()),

        // Col 2: Information
        Expanded(
          flex: 2,
          child: _buildLinkColumn('Information', [
            'About us',
            'Contact us',
            'Terms & Conditions',
            'Privacy Policy',
          ]),
        ),

        // Col 3: Shop By
        Expanded(
          flex: 2,
          child: _buildLinkColumn('Shop By', [
            'Eye Ware',
            'Organic Foods',
            'Pet Goods',
            'New Arrivals',
          ]),
        ),

        // Col 4: Support
        Expanded(
          flex: 2,
          child: _buildLinkColumn('Support', [
            'Support Center',
            'How to Order',
            'Order Tracking',
            'FAQ',
          ]),
        ),

        // Col 5: Consumer Policy
        Expanded(
          flex: 2,
          child: _buildLinkColumn('Consumer Policy', [
            'Happy Return',
            'Refund Policy',
            'Exchange',
            'Cancellation',
          ]),
        ),
      ],
    );
  }

  // ==========================================
  // MOBILE LAYOUT (Stacked)
  // ==========================================
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandInfo(),
        const SizedBox(height: 40),
        _buildLinkColumn('Information', [
          'About us',
          'Contact us',
          'Terms & Conditions',
          'Privacy Policy',
        ]),
        const SizedBox(height: 30),
        _buildLinkColumn('Shop By', [
          'Eye Ware',
          'Organic Foods',
          'Pet Goods',
          'New Arrivals',
        ]),
        const SizedBox(height: 30),
        _buildLinkColumn('Support', [
          'Support Center',
          'How to Order',
          'Order Tracking',
          'FAQ',
        ]),
        const SizedBox(height: 30),
        _buildLinkColumn('Consumer Policy', [
          'Happy Return',
          'Refund Policy',
          'Exchange',
          'Cancellation',
        ]),
      ],
    );
  }

  // ==========================================
  // WIDGET COMPONENTS
  // ==========================================

  Widget _buildBrandInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Image.asset(
          'assets/logo.webp',
          height: 60,
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
        const SizedBox(height: 16),

        // Description
        const Text(
          'FADHL is a premium e-commerce platform dedicated to providing safe, reliable, and luxury goods to every home.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 20),

        // Contact Details
        _iconText(FontAwesomeIcons.locationDot, 'Rampura, Dhaka, Bangladesh'),
        const SizedBox(height: 10),
        _iconText(FontAwesomeIcons.phone, '+88 0123 456 789'),
        const SizedBox(height: 10),
        _iconText(FontAwesomeIcons.envelope, 'contact@fadhl.com'),
        const SizedBox(height: 24),

        // Social Icons
        Row(
          children: [
            _socialIcon(FontAwesomeIcons.facebookF),
            _socialIcon(FontAwesomeIcons.twitter),
            _socialIcon(FontAwesomeIcons.instagram),
            _socialIcon(FontAwesomeIcons.youtube),
          ],
        ),
      ],
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      children: [
        FaIcon(icon, color: brandGold, size: 16),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:  0.05),
        shape: BoxShape.circle,
        border: Border.all(color: brandGold.withValues(alpha:  0.5)),
      ),
      child: FaIcon(icon, color: brandGold, size: 14),
    );
  }

  Widget _buildLinkColumn(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: brandGold,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () {},
              child: Text(
                link,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopBottomStrip() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '© 2026 FADHL. All Rights Reserved.',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        Row(
          children: [
            FaIcon(FontAwesomeIcons.ccVisa, color: Colors.white54, size: 24),
            const SizedBox(width: 12),
            FaIcon(
              FontAwesomeIcons.ccMastercard,
              color: Colors.white54,
              size: 24,
            ),
            const SizedBox(width: 12),
            FaIcon(FontAwesomeIcons.ccAmex, color: Colors.white54, size: 24),
            const SizedBox(width: 12),
            FaIcon(FontAwesomeIcons.ccStripe, color: Colors.white54, size: 24),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileBottomStrip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.ccVisa, color: Colors.white54, size: 24),
            const SizedBox(width: 12),
            FaIcon(
              FontAwesomeIcons.ccMastercard,
              color: Colors.white54,
              size: 24,
            ),
            const SizedBox(width: 12),
            FaIcon(FontAwesomeIcons.ccAmex, color: Colors.white54, size: 24),
            const SizedBox(width: 12),
            FaIcon(FontAwesomeIcons.ccStripe, color: Colors.white54, size: 24),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          '© 2026 FADHL. All Rights Reserved.',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}