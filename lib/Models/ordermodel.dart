import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String status;
  final double totalAmount;
  final double subtotal;
  final double deliveryCharge;
  final String source;
  final String customerName;
  final String customerPhone;
  final String shippingAddress;
  final String paymentMethod;
  final String adminFeedback;
  final List<dynamic> items;
  final DateTime? createdAt;

  OrderModel({
    required this.orderId,
    required this.status,
    required this.totalAmount,
    required this.subtotal,
    required this.deliveryCharge,
    required this.source,
    required this.customerName,
    required this.customerPhone,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.adminFeedback,
    required this.items,
    this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
    // Safely handle Firebase Timestamps
    DateTime? parsedDate;
    if (map['createdAt'] != null && map['createdAt'] is Timestamp) {
      parsedDate = (map['createdAt'] as Timestamp).toDate();
    }

    return OrderModel(
      orderId: map['orderId'] ?? documentId,
      // WhatsApp has "status: Pending - WhatsApp". Website has "status: Pending"
      status: map['status'] ?? map['orderstatus'] ?? 'Pending',

      // Safely handle Numbers (Converts int64 to double perfectly)
      totalAmount:
          (map['totalAmount'] != null)
              ? (map['totalAmount'] as num).toDouble()
              : 0.0,
      subtotal:
          (map['subtotal'] != null) ? (map['subtotal'] as num).toDouble() : 0.0,
      deliveryCharge:
          (map['deliveryCharge'] != null)
              ? (map['deliveryCharge'] as num).toDouble()
              : 0.0,

      source: map['source'] ?? 'Unknown',
      customerName: map['customerName'] ?? 'Guest',
      customerPhone: map['customerPhone'] ?? 'Pending',
      shippingAddress: map['shippingAddress'] ?? 'Pending',

      // If it's a WhatsApp order, it won't have a payment method, so we set a default!
      paymentMethod: map['paymentMethod'] ?? 'Manual (WhatsApp)',

      // Handles your uppercase vs lowercase field difference!
      adminFeedback:
          map['adminFeedback'] ?? map['adminfeedback'] ?? 'No Feedback',

      items: List<dynamic>.from(map['items'] ?? []),
      createdAt: parsedDate,
    );
  }
}
