import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../Widgers/Reuseable/responsive_headermenu.dart'; // Adjust path if needed
import '../../Widgers/responsive_layout.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  final Color brandGreen = const Color(0xFF0A1F13);
  final Color brandGold = const Color(0xFFCEAB5F);

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          CustomHeader(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. HERO BANNER (Full width green aesthetic)
                  _buildHeroBanner(isDesktop),

                  // 2. OUR STORY SECTION
                  ResponsiveLayout(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 60.0,
                      ),
                      child:
                          isDesktop
                              ? _buildDesktopStory()
                              : _buildMobileStory(),
                    ),
                  ),

                  // 3. CORE VALUES SECTION
                  ResponsiveLayout(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Why Choose FADHL?',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: brandGreen,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'The pillars of our premium service.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          const SizedBox(height: 40),
                          isDesktop
                              ? _buildDesktopValues()
                              : _buildMobileValues(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),
                  // const CustomFooter(), // Uncomment if you have your massive footer ready!
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 1. HERO BANNER
  // ==========================================
  Widget _buildHeroBanner(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 80 : 50,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: brandGreen,
        image: DecorationImage(
          image: const NetworkImage(
            'https://images.unsplash.com/photo-1600880292203-757bb62b4baf?q=80&w=2000&auto=format&fit=crop',
          ),
           // Abstract luxury dark background
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            brandGreen.withValues(alpha: 0.85),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/logo.webp',
            height: 80,
            errorBuilder: (c, e, s) => const SizedBox(),
          ),
          const SizedBox(height: 20),
          Text(
            'Redefining Luxury E-Commerce',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: brandGold,
              fontSize: isDesktop ? 42 : 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 600,
            child: Text(
              'Providing safe, reliable, and premium goods to every home in Bangladesh.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: isDesktop ? 18 : 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. OUR STORY (Desktop vs Mobile)
  // ==========================================
  Widget _buildDesktopStory() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?q=80&w=1000&auto=format&fit=crop', // Professional office/store image
              height: 400,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 60),
        Expanded(flex: 1, child: _storyTextContent(isDesktop: true)),
      ],
    );
  }

  Widget _buildMobileStory() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?q=80&w=1000&auto=format&fit=crop',
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 30),
        _storyTextContent(isDesktop: false),
      ],
    );
  }

  Widget _storyTextContent({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our Story',
          style: TextStyle(
            color: brandGold,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'A Commitment to Excellence.',
          style: TextStyle(
            fontSize: isDesktop ? 36 : 28,
            fontWeight: FontWeight.w900,
            color: brandGreen,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'FADHL was founded with a singular vision: to bridge the gap between premium quality and everyday accessibility in Bangladesh. We noticed a lack of trust in online shopping, so we built a platform where transparency, authenticity, and customer satisfaction are not just promised, they are guaranteed.\n\nFrom 100% pure organic foods to luxury designer eye ware and premium pet goods, every item in our inventory is strictly vetted. When you shop with FADHL, you aren\'t just buying a product; you are investing in peace of mind.',
          style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.8),
        ),
      ],
    );
  }

  // ==========================================
  // 3. CORE VALUES (Desktop vs Mobile)
  // ==========================================
  Widget _buildDesktopValues() {
    return Row(
      children: [
        Expanded(
          child: _valueCard(
            FontAwesomeIcons.truckFast,
            'FAST',
            'Lightning-fast delivery across all districts in Bangladesh.',
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _valueCard(
            FontAwesomeIcons.shieldHalved,
            'SAFE',
            '100% authentic products with secure packaging and handling.',
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _valueCard(
            FontAwesomeIcons.handshake,
            'RELIABLE',
            '24/7 dedicated customer support and hassle-free returns.',
          ),
        ),
      ],
    );
  }

  Widget _buildMobileValues() {
    return Column(
      children: [
        _valueCard(
          FontAwesomeIcons.truckFast,
          'FAST',
          'Lightning-fast delivery across all districts in Bangladesh.',
        ),
        const SizedBox(height: 16),
        _valueCard(
          FontAwesomeIcons.shieldHalved,
          'SAFE',
          '100% authentic products with secure packaging and handling.',
        ),
        const SizedBox(height: 16),
        _valueCard(
          FontAwesomeIcons.handshake,
          'RELIABLE',
          '24/7 dedicated customer support and hassle-free returns.',
        ),
      ],
    );
  }

  Widget _valueCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: brandGreen.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: FaIcon(icon, color: brandGold, size: 28),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: brandGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: Colors.black54,
              height: 1.5,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
