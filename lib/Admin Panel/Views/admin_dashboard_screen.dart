import 'package:fadhl/Admin%20Panel/Controllers/admin_order_controller.dart';
import 'package:fadhl/Admin%20Panel/Controllers/admin_product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/authcontroller.dart';
import '../Utils/global_colours.dart';
import 'Banner/banner_view.dart';
import 'Customer/customer_view.dart';
import 'Orders/order_processing_modal.dart';
import 'Orders/orderview.dart';
import 'Product/product_view.dart';
import 'admin_aboutus_view.dart';
import 'admin_account_view.dart';
import 'admin_policy_view.dart';
import 'faq_view.dart';
import 'shipping_view.dart';
import 'admin_terms_view.dart';

class AdminDashboardScreen extends StatelessWidget {
  AdminDashboardScreen({super.key});

  final RxInt _currentIndex = 0.obs;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final AdminControllerProductmanagement adminProductController = Get.put(
    AdminControllerProductmanagement(),
  );
  final AdminOrderManagementController adminOrderController = Get.put(
    AdminOrderManagementController(),
  );

  final MenuController notificationMenuController = MenuController();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundLight,
      drawer:
          isDesktop
              ? null
              : Drawer(
                backgroundColor: AppColors.pureWhite,
                child: _buildSidebarContent(isMobile: true),
              ),
      body: Row(
        children: [
          if (isDesktop)
            Container(
              width: 260,
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                border: Border(
                  right: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: _buildSidebarContent(isMobile: false),
            ),
          Expanded(
            child: Column(
              children: [
                _buildTopHeader(isDesktop),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isDesktop ? 40.0 : 16.0),
                    child: Obx(() {
                      if (_currentIndex.value == 0) {
                        return OrdersView(isDesktop: isDesktop);
                      }
                      if (_currentIndex.value == 1) {
                        return ProductsView(isDesktop: isDesktop);
                      }
                      if (_currentIndex.value == 2) {
                        return AdminCustomerView(isDesktop: isDesktop);
                      }
                      if (_currentIndex.value == 3) {
                        return AdminBannerView(isDesktop: isDesktop);
                      }
                      if (_currentIndex.value == 4) {
                        return AdminManagementView(isDesktop: isDesktop);
                      }
                      if (_currentIndex.value == 5) {
                        return AdminShippingAreaView(isDesktop: isDesktop);
                      }
                      if (_currentIndex.value == 6) {
                        return AdminFaqView(isDesktop: isDesktop);
                      }
                      if (_currentIndex.value == 7) {
                        return AdminAboutUsView(isDesktop: isDesktop);
                      }
                      if (_currentIndex.value == 8) {
                        return AdminTermsView(isDesktop: isDesktop);
                      }
                      // 🚀 ADDED ROUTE FOR POLICIES (Index 9)
                      return AdminPolicyView(isDesktop: isDesktop);
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : _buildMobileBottomNav(),
    );
  }

  Widget _buildSidebarContent({required bool isMobile}) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Image.asset(
          'assets/logo.webp',
          height: 80,
          errorBuilder:
              (c, e, s) => const Text(
                'FADHL',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
        ),
        const SizedBox(height: 10),
        const Text(
          'ADMIN PANEL',
          style: TextStyle(
            color: Colors.grey,
            letterSpacing: 2,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _sidebarItem(0, Icons.assignment, 'Order Management', isMobile),
                _sidebarItem(
                  1,
                  Icons.inventory_2,
                  'Products Inventory',
                  isMobile,
                ),
                _sidebarItem(2, Icons.group, 'Customers', isMobile),
                _sidebarItem(
                  3,
                  Icons.view_carousel,
                  'Homepage Banners',
                  isMobile,
                ),
                _sidebarItem(
                  4,
                  Icons.admin_panel_settings,
                  'Staff & Admins',
                  isMobile,
                ),
                _sidebarItem(
                  5,
                  Icons.local_shipping,
                  'Shipping Areas',
                  isMobile,
                ),
                _sidebarItem(6, Icons.help_outline, 'Manage FAQs', isMobile),
                _sidebarItem(
                  7,
                  Icons.info_outline,
                  'Manage About Us',
                  isMobile,
                ),
                _sidebarItem(
                  8,
                  Icons.description,
                  'Terms & Conditions',
                  isMobile,
                ),
                _sidebarItem(9, Icons.security, 'Manage Policies', isMobile),
              ],
            ),
          ),
        ),

        Divider(color: Colors.grey.shade200, height: 1),

        ListTile(
          leading: Icon(
            Icons.storefront,
            color: Colors.grey.shade700,
            size: 20,
          ),
          title: Text(
            'View Store',
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () => Get.offAllNamed('/'),
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
          title: const Text(
            'Logout',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () => Get.find<AuthController>().logout(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _sidebarItem(int index, IconData icon, String title, bool isMobile) {
    return Obx(() {
      final isSelected = _currentIndex.value == index;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primaryGreen.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected
                    ? AppColors.primaryGreen.withValues(alpha: 0.3)
                    : Colors.transparent,
          ),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? AppColors.primaryGreen : Colors.grey.shade600,
            size: 20,
          ),
          title: Text(
            title,
            style: TextStyle(
              color:
                  isSelected
                      ? AppColors.primaryGreen
                      : AppColors.textDark.withValues(alpha: 0.8),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          onTap: () {
            _currentIndex.value = index;
            if (isMobile) Get.back();
          },
        ),
      );
    });
  }

  Widget _buildTopHeader(bool isDesktop) {
    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (!isDesktop) ...[
                IconButton(
                  icon: Icon(Icons.sort, color: AppColors.primaryGreen),
                  onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                ),
                const SizedBox(width: 12),
              ],
              Obx(() {
                String title = 'Order Management';
                if (_currentIndex.value == 1) title = 'Products Inventory';
                if (_currentIndex.value == 2) title = 'Customer Insights';
                if (_currentIndex.value == 3) title = 'Banner Controller';
                if (_currentIndex.value == 4) title = 'Staff & Admins';
                if (_currentIndex.value == 5) title = 'Shipping Areas';
                if (_currentIndex.value == 6) title = 'Manage FAQs';
                if (_currentIndex.value == 7) title = 'Manage About Us';
                if (_currentIndex.value == 8) title = 'Terms & Conditions';
                // 🚀 ADDED TITLE FOR POLICIES PAGE
                if (_currentIndex.value == 9) title = 'Manage Policies';

                return Text(
                  title,
                  style: TextStyle(
                    fontSize: isDesktop ? 24 : 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                  ),
                );
              }),
            ],
          ),
          Row(
            children: [
              _buildNotificationCenter(),
              SizedBox(width: isDesktop ? 24 : 16),
              CircleAvatar(
                backgroundColor: AppColors.primaryGold.withValues(alpha: 0.2),
                child: const Icon(
                  Icons.verified_user,
                  color: AppColors.primaryGold,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCenter() {
    return MenuAnchor(
      controller: notificationMenuController,
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.pureWhite),
        elevation: WidgetStateProperty.all(12),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      builder: (context, controller, child) {
        return Obx(() {
          int count = adminOrderController.pendingOrders.length;
          return InkWell(
            onTap:
                () =>
                    controller.isOpen ? controller.close() : controller.open(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications,
                  color: Colors.grey.shade600,
                  size: 24,
                ),
                if (count > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.pureWhite,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
      },
      menuChildren: [
        Container(
          width: 350,
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Pending Orders',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: Obx(() {
                  if (adminOrderController.pendingOrders.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'All caught up!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return Scrollbar(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            adminOrderController.pendingOrders.map<Widget>((
                              order,
                            ) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: const Icon(
                                    Icons.lock_clock,
                                    color: Colors.orange,
                                    size: 16,
                                  ),
                                ),
                                title: Text(
                                  '#${order['orderId']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                subtitle: Text(
                                  order['customerName'] ?? 'Unknown',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                trailing: Text(
                                  '৳${(order['totalAmount'] ?? 0).toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  notificationMenuController.close();
                                  openOrderProcessingModal(order);
                                },
                              );
                            }).toList(),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBottomNav() {
    return Obx(
      () => BottomNavigationBar(
        currentIndex: _currentIndex.value,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: Colors.grey.shade400,
        backgroundColor: AppColors.pureWhite,
        elevation: 10,
        selectedFontSize: 9,
        unselectedFontSize: 9,
        onTap: (index) => _currentIndex.value = index,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment, size: 16), // Replaced clipboardList
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2, size: 16), // Replaced boxOpen
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, size: 16), // Replaced users
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune, size: 16), // Replaced sliders
            label: 'Banner',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.admin_panel_settings,
              size: 16,
            ), // Replaced userShield
            label: 'Admins',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping, size: 16), // Replaced truckFast
            label: 'Ship',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline, size: 16), // Replaced circleQuestion
            label: 'FAQs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline, size: 16), // Replaced circleInfo
            label: 'About',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description, size: 16), // Replaced fileContract
            label: 'Terms',
          ),
          // 🚀 ADDED POLICIES TO MOBILE NAV
          BottomNavigationBarItem(
            icon: Icon(Icons.policy, size: 16), // Replaced shieldHalved
            label: 'Policy',
          ),
        ],
      ),
    );
  }
}
