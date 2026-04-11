import 'package:fadhl/Models/ordermodel.dart';
import 'package:fadhl/Widgers/Reuseable/responsive_bottomnavbar.dart';
import 'package:fadhl/Widgers/Reuseable/responsive_headermenu.dart';
import 'package:fadhl/Widgers/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  final Color brandGreen = const Color(0xFF0A1F13);
  final Color brandGold = const Color(0xFFCEAB5F);

  @override
  Widget build(BuildContext context) {
    // Web Refresh Safety Check (Browser Back Button Safe)
    if (Get.arguments == null) {
      Future.microtask(() => Get.offAllNamed('/'));
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: const SizedBox.shrink(),
      );
    }

    final OrderModel order = Get.arguments as OrderModel;
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Column(
        children: [
          CustomHeader(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ResponsiveLayout(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16.0 : 40.0,
                        vertical: 40.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // BACK BUTTON
                          InkWell(
                            onTap: () => Get.back(),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.arrowLeft,
                                  size: 16,
                                  color: brandGreen,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Back',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: brandGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // PAGE TITLE
                          const Text(
                            'Track Your Order',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ==========================================
                          // THE TRACKING RECEIPT CARD
                          // ==========================================
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(isMobile ? 20 : 32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // --- HEADER ROW ---
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'ORDER ID',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          order.orderId,
                                          style: TextStyle(
                                            fontSize: isMobile ? 18 : 22,
                                            fontWeight: FontWeight.w900,
                                            color: brandGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: brandGold.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: brandGold),
                                      ),
                                      child: Text(
                                        order.status.toUpperCase(),
                                        style: TextStyle(
                                          color: brandGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: isMobile ? 10 : 12,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                const Divider(),
                                const SizedBox(height: 24),

                                // --- DETAILS GRID ---
                                Wrap(
                                  spacing: 40,
                                  runSpacing: 24,
                                  children: [
                                    _infoBlock(
                                      'Customer',
                                      order.customerName,
                                      FontAwesomeIcons.solidUser,
                                    ),
                                    _infoBlock(
                                      'Phone',
                                      order.customerPhone,
                                      FontAwesomeIcons.phone,
                                    ),
                                    _infoBlock(
                                      'Order Date',
                                      order.createdAt != null
                                          ? "${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}"
                                          : "N/A",
                                      FontAwesomeIcons.calendarDay,
                                    ),
                                    _infoBlock(
                                      'Payment Method',
                                      order.paymentMethod,
                                      FontAwesomeIcons.creditCard,
                                    ),
                                    _infoBlock(
                                      'Order Source',
                                      order.source,
                                      FontAwesomeIcons.globe,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _infoBlock(
                                  'Shipping Address',
                                  order.shippingAddress,
                                  FontAwesomeIcons.locationDot,
                                ),

                                // --- ADMIN FEEDBACK (If any) ---
                                if (order.adminFeedback != 'No Feedback' &&
                                    order.adminFeedback.isNotEmpty) ...[
                                  const SizedBox(height: 24),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.blue.shade100,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Note from FADHL:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          order.adminFeedback,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 32),
                                const Text(
                                  'Order Items',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // --- ITEMS LIST ---
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: order.items.length,
                                  separatorBuilder:
                                      (_, __) =>
                                          Divider(color: Colors.grey.shade100),
                                  itemBuilder: (context, index) {
                                    final item = order.items[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                item['image'] ??
                                                    'https://via.placeholder.com/50',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['name'] ?? 'Product',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  'Qty: ${item['quantity']}',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '৳${item['price']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 24),
                                const Divider(),
                                const SizedBox(height: 16),

                                // --- TOTAL MATH ---
                                // Only show Subtotal & Delivery if it's a Website Order (subtotal > 0)
                                if (order.subtotal > 0) ...[
                                  _mathRow('Subtotal', order.subtotal),
                                  const SizedBox(height: 8),
                                  _mathRow(
                                    'Delivery Charge',
                                    order.deliveryCharge,
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Grand Total',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '৳${order.totalAmount.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: brandGold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const CustomFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBlock(String title, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, size: 12, color: brandGold),
            const SizedBox(width: 6),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _mathRow(String title, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
        Text(
          '৳${amount.toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
