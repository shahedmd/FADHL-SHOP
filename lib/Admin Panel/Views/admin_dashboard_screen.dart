import 'package:fadhl/Admin%20Panel/Controllers/admin_order_controller.dart';
import 'package:fadhl/Admin%20Panel/Controllers/admin_product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../Controllers/authcontroller.dart';

import '../Utils/global_colours.dart';
import 'Customer/customer_view.dart';
import 'Orders/order_processing_modal.dart';
import 'Orders/orderview.dart';
import 'Product/product_view.dart';
import 'admin_account_view.dart';

class AdminDashboardScreen extends StatelessWidget {
  AdminDashboardScreen({super.key});

  final RxInt _currentIndex = 0.obs;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 🚀 Initialize Controllers
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
      backgroundColor: const Color(0xFFF4F7F6),
      drawer:
          isDesktop
              ? null
              : Drawer(
                backgroundColor: brandGreen,
                child: _buildSidebarContent(isMobile: true),
              ),
      body: Row(
        children: [
          if (isDesktop)
            Container(
              width: 260,
              color: brandGreen,
              child: _buildSidebarContent(isMobile: false),
            ),
          Expanded(
            child: Column(
              children: [
                _buildTopHeader(isDesktop),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isDesktop ? 40.0 : 16.0),
                    // 🚀 MUCH CLEANER VIEW SWITCHING
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
                      return AdminManagementView(
                        isDesktop: isDesktop,
                      ); // 🚀 The New Tab!
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

  // ==========================================
  // SIDEBAR WIDGETS
  // ==========================================
  Widget _buildSidebarContent({required bool isMobile}) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Image.asset(
          'assets/logo.webp',
          height: 80,
          errorBuilder:
              (c, e, s) => Text(
                'FADHL',
                style: TextStyle(
                  color: brandGold,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
        const SizedBox(height: 10),
        const Text(
          'ADMIN PANEL',
          style: TextStyle(
            color: Colors.white54,
            letterSpacing: 2,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 50),

        _sidebarItem(
          0,
          FontAwesomeIcons.clipboardList,
          'Order Management',
          isMobile,
        ),
        _sidebarItem(
          1,
          FontAwesomeIcons.boxOpen,
          'Products Inventory',
          isMobile,
        ),
        _sidebarItem(2, FontAwesomeIcons.users, 'Customers', isMobile),
        _sidebarItem(
          3,
          FontAwesomeIcons.userShield,
          'Staff & Admins',
          isMobile,
        ),

        const Spacer(),
        const Divider(color: Colors.white12),

        ListTile(
          leading: const FaIcon(
            FontAwesomeIcons.store,
            color: Colors.white70,
            size: 20,
          ),
          title: const Text(
            'View Store',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap:
              () => Get.offAllNamed('/'), // Safely routes to the main website!
        ),
        ListTile(
          leading: const FaIcon(
            FontAwesomeIcons.arrowRightFromBracket,
            color: Colors.redAccent,
            size: 20,
          ),
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
                  ? brandGold.withValues(alpha: 0.15)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected
                    ? brandGold.withValues(alpha: 0.5)
                    : Colors.transparent,
          ),
        ),
        child: ListTile(
          leading: FaIcon(
            icon,
            color: isSelected ? brandGold : Colors.white70,
            size: 20,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? brandGold : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () {
            _currentIndex.value = index;
            if (isMobile) Get.back(); // Close drawer on mobile
          },
        ),
      );
    });
  }

  // ==========================================
  // TOP HEADER & NOTIFICATIONS
  // ==========================================
  Widget _buildTopHeader(bool isDesktop) {
    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (!isDesktop) ...[
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.barsStaggered,
                    color: brandGreen,
                  ),
                  onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                ),
                const SizedBox(width: 12),
              ],
              Obx(() {
                String title = 'Order Management';
                if (_currentIndex.value == 1) title = 'Products Inventory';
                if (_currentIndex.value == 2) title = 'Customer Insights';
                if (_currentIndex.value == 3) title = 'Staff & Admins';
                return Text(
                  title,
                  style: TextStyle(
                    fontSize: isDesktop ? 24 : 18,
                    fontWeight: FontWeight.w900,
                    color: brandGreen,
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
                backgroundColor: brandGold.withValues(alpha: 0.2),
                child: FaIcon(
                  FontAwesomeIcons.solidUser,
                  color: brandGold,
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
        backgroundColor: WidgetStateProperty.all(Colors.white),
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
                FaIcon(
                  FontAwesomeIcons.bell,
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
                        border: Border.all(color: Colors.white, width: 1.5),
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Pending Orders',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: brandGreen,
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
                                  child: const FaIcon(
                                    FontAwesomeIcons.clock,
                                    color: Colors.orange,
                                    size: 16,
                                  ),
                                ),
                                title: Text(
                                  '#${order['orderId']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  order['customerName'] ?? 'Unknown',
                                ),
                                trailing: Text(
                                  '৳${(order['totalAmount'] ?? 0).toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: brandGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  notificationMenuController.close();
                                  openOrderProcessingModal(
                                    order,
                                  ); // 🚀 Opens the extracted modal!
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

  // ==========================================
  // MOBILE BOTTOM NAVIGATION
  // ==========================================
  Widget _buildMobileBottomNav() {
    return Obx(
      () => BottomNavigationBar(
        currentIndex: _currentIndex.value,
        selectedItemColor: brandGreen,
        unselectedItemColor: Colors.grey.shade400,
        backgroundColor: Colors.white,
        elevation: 10,
        onTap: (index) => _currentIndex.value = index,
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.clipboardList, size: 20),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.boxOpen, size: 20),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.users, size: 20),
            label: 'Customers',
          ), // 🚀 CUSTOMER TAB

          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.userShield, size: 20),
            label: 'Admins',
          ),
        ],
      ),
    );
  }
}
