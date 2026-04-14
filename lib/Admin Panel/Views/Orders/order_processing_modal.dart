import 'package:fadhl/Admin%20Panel/Controllers/admin_order_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

// Make sure these paths match your folder structure exactly
import '../../Services/pdf_invoice_services.dart';
import '../../Utils/global_colours.dart'; // Make sure your AppColors class is in here!

void openOrderProcessingModal(Map<String, dynamic> order) {
  final adminOrderController = Get.find<AdminOrderManagementController>();

  final String orderId = order['orderId']?.toString() ?? 'Unknown';
  final List items = order['items'] ?? [];

  double subtotal = 0;
  for (var item in items) {
    subtotal += ((item['price'] ?? 0) * (item['quantity'] ?? 1));
  }
  double delivery = 120.0;
  double originalTotal = subtotal + delivery;

  // 🚀 Isolated Reactive GetX Variables
  final RxDouble currentDiscount =
      ((order['discount'] ?? 0) as num).toDouble().obs;
  final RxDouble currentGrandTotal =
      ((order['totalAmount'] ?? 0) as num).toDouble().obs;
  final RxString currentStatus =
      (order['orderstatus']?.toString() ??
              order['status']?.toString() ??
              'Pending')
          .obs;

  // Reactive variables for Customer Details
  final RxString currentCustomerName =
      (order['customerName']?.toString() ?? 'Unknown').obs;
  final RxString currentCustomerPhone =
      (order['customerPhone']?.toString() ?? 'Unknown').obs;
  final RxBool isEditingCustomer = false.obs;

  // 🚀 NEW: Reactive variables for Addresses
  final RxString currentShipping =
      (order['shippingAddress']?.toString() ?? 'Not Provided').obs;
  final RxString currentBilling =
      (order['billingAddress']?.toString() ?? 'Not Provided').obs;
  final RxBool isEditingAddresses = false.obs;

  final String initialFeedback = (order['adminfeedback'] ?? '').toString();

  // Existing Controllers
  final TextEditingController feedbackController = TextEditingController(
    text: initialFeedback == 'No Feedback' ? '' : initialFeedback,
  );
  final TextEditingController discountController = TextEditingController(
    text:
        currentDiscount.value > 0
            ? currentDiscount.value.toStringAsFixed(0)
            : '',
  );

  // Controllers for Editing Customer Info
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // 🚀 NEW: Controllers for Editing Addresses
  final TextEditingController shippingController = TextEditingController();
  final TextEditingController billingController = TextEditingController();

  Get.dialog(
    Dialog(
      backgroundColor: AppColors.pureWhite, // Updated to AppColors
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 800,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(Get.context!).size.height * 0.85,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen, // Updated
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #$orderId',
                    style: const TextStyle(
                      color: AppColors.primaryGold, // Updated
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(Get.context!).pop(),
                  ),
                ],
              ),
            ),

            // BODY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isModalDesktop = constraints.maxWidth > 600;

                    Widget leftPanel = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  AppColors.primaryGreen, // Updated
                              side: const BorderSide(
                                color: AppColors.primaryGreen,
                              ), // Updated
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed:
                                () => PdfInvoiceService.generateAndPreviewPDF(
                                  order,
                                ),
                            icon: const FaIcon(
                              FontAwesomeIcons.solidFilePdf,
                              size: 18,
                              color: Colors.redAccent,
                            ),
                            label: const Text(
                              'Print / Preview Invoice',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ==============================
                        // CUSTOMER DETAILS CARD
                        // ==============================
                        const Text(
                          'Customer Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight, // Updated
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Obx(() {
                            // EDIT MODE (CUSTOMER)
                            if (isEditingCustomer.value) {
                              return Column(
                                children: [
                                  TextField(
                                    controller: nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Customer Name',
                                      isDense: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      labelText: 'Phone Number',
                                      isDense: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed:
                                            () =>
                                                isEditingCustomer.value = false,
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryGreen, // Updated
                                          foregroundColor:
                                              AppColors.primaryGold, // Updated
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          adminOrderController
                                              .updateCustomerDetails(
                                                orderId,
                                                nameController.text.trim(),
                                                phoneController.text.trim(),
                                              );
                                          currentCustomerName.value =
                                              nameController.text.trim();
                                          currentCustomerPhone.value =
                                              phoneController.text.trim();
                                          isEditingCustomer.value = false;
                                        },
                                        child: const Text('Save'),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }

                            // VIEW MODE (CUSTOMER)
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentCustomerName.value,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppColors.textDark, // Updated
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const FaIcon(
                                          FontAwesomeIcons.phone,
                                          size: 14,
                                          color: Colors.black54,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          currentCustomerPhone.value,
                                          style: const TextStyle(
                                            color: AppColors.textDark,
                                          ), // Updated
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blueGrey,
                                    size: 20,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    nameController.text =
                                        currentCustomerName.value == 'Unknown'
                                            ? ''
                                            : currentCustomerName.value;
                                    phoneController.text =
                                        currentCustomerPhone.value == 'Unknown'
                                            ? ''
                                            : currentCustomerPhone.value;
                                    isEditingCustomer.value = true;
                                  },
                                ),
                              ],
                            );
                          }),
                        ),

                        const SizedBox(height: 24),

                        // 🚀 ==============================
                        // 🚀 NEW: ADDRESS DETAILS CARD
                        // 🚀 ==============================
                        const Text(
                          'Address Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight, // Updated
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Obx(() {
                            // EDIT MODE (ADDRESSES)
                            if (isEditingAddresses.value) {
                              return Column(
                                children: [
                                  TextField(
                                    controller: shippingController,
                                    maxLines: 2,
                                    decoration: InputDecoration(
                                      labelText: 'Shipping Address',
                                      alignLabelWithHint: true,
                                      isDense: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: billingController,
                                    maxLines: 2,
                                    decoration: InputDecoration(
                                      labelText: 'Billing Address',
                                      alignLabelWithHint: true,
                                      isDense: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed:
                                            () =>
                                                isEditingAddresses.value =
                                                    false,
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryGreen, // Updated
                                          foregroundColor:
                                              AppColors.primaryGold, // Updated
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          adminOrderController
                                              .updateOrderAddresses(
                                                orderId,
                                                shippingController.text.trim(),
                                                billingController.text.trim(),
                                              );
                                          currentShipping.value =
                                              shippingController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? 'Not Provided'
                                                  : shippingController.text
                                                      .trim();
                                          currentBilling.value =
                                              billingController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? 'Not Provided'
                                                  : billingController.text
                                                      .trim();
                                          isEditingAddresses.value = false;
                                        },
                                        child: const Text('Save'),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }

                            // VIEW MODE (ADDRESSES)
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Shipping Address:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        currentShipping.value,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color:
                                              currentShipping.value ==
                                                          'Pending' ||
                                                      currentShipping.value ==
                                                          'Not Provided'
                                                  ? Colors.redAccent
                                                  : AppColors
                                                      .textDark, // Updated
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Billing Address:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        currentBilling.value,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color:
                                              currentBilling.value ==
                                                          'Pending' ||
                                                      currentBilling.value ==
                                                          'Not Provided'
                                                  ? Colors.redAccent
                                                  : AppColors
                                                      .textDark, // Updated
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blueGrey,
                                    size: 20,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    shippingController.text =
                                        (currentShipping.value ==
                                                    'Not Provided' ||
                                                currentShipping.value ==
                                                    'Pending')
                                            ? ''
                                            : currentShipping.value;
                                    billingController.text =
                                        (currentBilling.value ==
                                                    'Not Provided' ||
                                                currentBilling.value ==
                                                    'Pending')
                                            ? ''
                                            : currentBilling.value;
                                    isEditingAddresses.value = true;
                                  },
                                ),
                              ],
                            );
                          }),
                        ),

                        const SizedBox(height: 24),
                        const Text(
                          'Invoice Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              ...items.map(
                                (item) => ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      item['image']?.toString() ??
                                          'https://via.placeholder.com/50',
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    item['name']?.toString() ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: AppColors.textDark, // Updated
                                    ),
                                  ),
                                  subtitle: Text('Qty: ${item['quantity']}'),
                                  trailing: Text(
                                    '৳${item['price']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark, // Updated
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundLight, // Updated
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Subtotal:'),
                                        Text('৳$subtotal'),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Delivery:'),
                                        Text('৳$delivery'),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Discount:',
                                          style: TextStyle(
                                            color: AppColors.primaryGreen,
                                          ), // Updated
                                        ),
                                        Obx(
                                          () => Text(
                                            '- ৳${currentDiscount.value}',
                                            style: const TextStyle(
                                              color:
                                                  AppColors
                                                      .primaryGreen, // Updated
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withValues(
                                    alpha: 0.05,
                                  ), // Updated
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Grand Total',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppColors.textDark, // Updated
                                      ),
                                    ),
                                    Obx(
                                      () => Text(
                                        '৳${currentGrandTotal.value.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 20,
                                          color:
                                              AppColors.primaryGreen, // Updated
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

                    Widget rightPanel = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Admin Controls',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Apply Discount (৳)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.textDark, // Updated
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: discountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'e.g. 200',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.primaryGold, // Updated
                                foregroundColor:
                                    AppColors.primaryGreen, // Updated
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                double dAmount =
                                    double.tryParse(discountController.text) ??
                                    0;
                                adminOrderController.applyDiscount(
                                  orderId,
                                  originalTotal,
                                  dAmount,
                                );
                                currentDiscount.value = dAmount;
                                currentGrandTotal.value =
                                    originalTotal - dAmount;
                                if (currentGrandTotal.value < 0) {
                                  currentGrandTotal.value = 0;
                                }
                              },
                              child: const Text(
                                'Apply',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Update Status',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.textDark, // Updated
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => DropdownButtonFormField<String>(
                            value:
                                [
                                      'Pending',
                                      'Processing',
                                      'Shipped',
                                      'Delivered',
                                      'Cancelled',
                                      'Pending - WhatsApp',
                                      'Return',
                                    ].contains(currentStatus.value)
                                    ? currentStatus.value
                                    : 'Pending',
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                            items:
                                [
                                      'Pending',
                                      'Pending - WhatsApp',
                                      'Processing',
                                      'Shipped',
                                      'Delivered',
                                      'Cancelled',
                                      'Returned',
                                    ]
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(
                                          s,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (newStatus) {
                              if (newStatus != null) {
                                adminOrderController.updateOrderStatus(
                                  orderId,
                                  newStatus,
                                );
                                currentStatus.value = newStatus;
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Private Notes',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.textDark, // Updated
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: feedbackController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.backgroundLight, // Updated
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.primaryGreen, // Updated
                              foregroundColor: AppColors.primaryGold, // Updated
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed:
                                () => adminOrderController.updateAdminFeedback(
                                  orderId,
                                  feedbackController.text,
                                ),
                            icon: const Icon(Icons.save, size: 18),
                            label: const Text(
                              'Save Notes',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    );

                    return isModalDesktop
                        ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 6, child: leftPanel),
                            const SizedBox(width: 32),
                            Expanded(flex: 4, child: rightPanel),
                          ],
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            leftPanel,
                            const SizedBox(height: 32),
                            rightPanel,
                          ],
                        );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}