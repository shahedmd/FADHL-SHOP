import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Admin Panel/Utils/global_colours.dart'; // Ensure AppColors is inside this file
import '../../Widgers/Reuseable/responsive_headermenu.dart';
import '../../Widgers/responsive_layout.dart';
// import '../../Widgers/Reuseable/custom_footer.dart'; // Uncomment if using footer

class FaqScreen extends StatelessWidget {
  FaqScreen({super.key});
  final RxString selectedCategory = 'All'.obs;
  final List<String> categories = [
    'All',
    'Shipping & Delivery',
    'Payments',
    'Returns & Refunds',
    'Products',
  ];

  final List<Map<String, String>> faqs = [
    // Shipping
    {
      'category': 'Shipping & Delivery',
      'q': 'How much does delivery cost?',
      'a':
          'Standard delivery is ৳120 across all districts in Bangladesh. We occasionally offer free shipping during special promotional events.',
    },
    {
      'category': 'Shipping & Delivery',
      'q': 'How long will my order take to arrive?',
      'a':
          'Orders inside Dhaka are typically delivered within 24-48 hours. Deliveries outside Dhaka usually take 3-5 business days depending on the courier service.',
    },
    {
      'category': 'Shipping & Delivery',
      'q': 'Can I track my order?',
      'a':
          'Absolutely. Once your order is dispatched, you will receive an Order ID. You can click "Track Order" in the top menu to see its live status.',
    },

    // Payments
    {
      'category': 'Payments',
      'q': 'Do you offer Cash on Delivery (COD)?',
      'a':
          'Yes! We offer Cash on Delivery for all orders across Bangladesh. You can inspect your package before handing the cash to the delivery agent.',
    },
    {
      'category': 'Payments',
      'q': 'Can I pay using bKash or Nagad?',
      'a':
          'Yes, we accept secure mobile banking payments including bKash, Nagad, and Rocket during the checkout process.',
    },

    // Returns
    {
      'category': 'Returns & Refunds',
      'q': 'What is your return policy?',
      'a':
          'We offer a 3-day hassle-free return policy. If your product is damaged or incorrect, keep the original packaging and contact us immediately for a free replacement.',
    },
    {
      'category': 'Returns & Refunds',
      'q': 'How do I request a refund?',
      'a':
          'To request a refund, please contact our WhatsApp support team with your Order ID and a photo of the item. Refunds are processed within 3-5 working days.',
    },

    // Products
    {
      'category': 'Products',
      'q': 'Are your organic foods 100% authentic?',
      'a':
          'Yes. Our organic products are sourced directly from trusted local farmers and are strictly quality-tested to ensure zero chemical adulteration.',
    },
  ];

  // ==========================================
  // WHATSAPP REDIRECT (Support)
  // ==========================================
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

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight, // Updated to brand background
      body: Column(
        children: [
          const CustomHeader(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. HERO SECTION
                  _buildHeroSection(isDesktop),

                  // 2. MAIN CONTENT AREA
                  ResponsiveLayout(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 40.0,
                      ),
                      child:
                          isDesktop
                              ? _buildDesktopLayout()
                              : _buildMobileLayout(),
                    ),
                  ),

                  // 3. STILL NEED HELP CTA
                  ResponsiveLayout(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 20.0,
                      ),
                      child: _buildContactSupportCard(isDesktop),
                    ),
                  ),

                  const SizedBox(height: 60),
                  // const CustomFooter(), // Uncomment to add footer!
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // LAYOUTS
  // ==========================================
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildCategorySidebar()),
        const SizedBox(width: 60),
        Expanded(flex: 7, child: _buildFaqList()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryDropdown(), // Uses horizontal scroll on mobile
        const SizedBox(height: 30),
        _buildFaqList(),
      ],
    );
  }

  // ==========================================
  // COMPONENTS
  // ==========================================
  Widget _buildHeroSection(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 60 : 40,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen, // Updated
        image: DecorationImage(
          image: const NetworkImage(
            'https://images.unsplash.com/photo-1557425955-df376b5903c8?q=80&w=2000&auto=format&fit=crop',
          ), // Minimalist luxury texture
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            AppColors.primaryGreen.withValues(alpha: 0.9), // Updated
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        children: [
          const FaIcon(FontAwesomeIcons.circleQuestion, color: AppColors.primaryGold, size: 50), // Updated
          const SizedBox(height: 20),
          Text(
            'How can we help you?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.pureWhite, // Updated
              fontSize: isDesktop ? 42 : 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Find answers to frequently asked questions about FADHL.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.pureWhite.withValues(alpha: 0.7), // Updated
              fontSize: isDesktop ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySidebar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.pureWhite, // Updated
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen, // Updated
            ),
          ),
          const SizedBox(height: 20),
          ...categories.map(
            (category) => Obx(() {
              final isSelected = selectedCategory.value == category;
              return InkWell(
                onTap: () => selectedCategory.value = category,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppColors.primaryGreen.withValues(alpha: 0.05) // Updated
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryGold : Colors.transparent, // Updated
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? AppColors.primaryGreen : AppColors.textDark, // Updated
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Obx(() {
            final isSelected = selectedCategory.value == category;
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: ChoiceChip(
                label: Text(category),
                selected: isSelected,
                selectedColor: AppColors.primaryGreen, // Updated
                backgroundColor: AppColors.pureWhite, // Updated
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primaryGold : AppColors.textDark, // Updated
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300, // Updated
                  ),
                ),
                onSelected: (selected) {
                  if (selected) selectedCategory.value = category;
                },
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildFaqList() {
    return Obx(() {
      // Filter logic
      final filteredFaqs =
          selectedCategory.value == 'All'
              ? faqs
              : faqs
                  .where((faq) => faq['category'] == selectedCategory.value)
                  .toList();

      if (filteredFaqs.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(40.0),
          child: Center(
            child: Text(
              'No FAQs available in this category.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(), // Important to prevent scrolling conflicts
        itemCount: filteredFaqs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final faq = filteredFaqs[index];

          return Container(
            decoration: BoxDecoration(
              color: AppColors.pureWhite, // Updated
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Theme(
              // Removes the default ugly lines around ExpansionTile
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: AppColors.primaryGold, // Updated
                collapsedIconColor: AppColors.primaryGreen, // Updated
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                title: Text(
                  faq['q']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryGreen, // Updated
                  ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: 24,
                    ),
                    child: Text(
                      faq['a']!,
                      style: const TextStyle(
                        color: AppColors.textDark, // Updated to brand dark text
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildContactSupportCard(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.05), // Updated
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)), // Updated
      ),
      child:
          isDesktop
              ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _contactContent(isDesktop),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _contactContent(isDesktop),
              ),
    );
  }

  List<Widget> _contactContent(bool isDesktop) {
    return [
      Column(
        crossAxisAlignment:
            isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          const Text(
            'Still have questions?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen, // Updated
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our premium support team is here to help you 24/7.',
            style: TextStyle(
              color: AppColors.textDark.withValues(alpha: 0.7), // Updated
              fontSize: 15,
            ),
          ),
        ],
      ),
      if (!isDesktop) const SizedBox(height: 24),
      SizedBox(
        height: 50,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366), // WhatsApp Green (Left as is!)
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            elevation: 0,
          ),
          onPressed: _contactSupport,
          icon: const FaIcon(
            FontAwesomeIcons.whatsapp,
            color: Colors.white,
            size: 20,
          ),
          label: const Text(
            'Chat on WhatsApp',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    ];
  }
}