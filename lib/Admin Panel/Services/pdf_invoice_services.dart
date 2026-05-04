import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// ✅ Browser window — zero cost, built into every browser
@JS('window.open')
external JSObject _openWindow(String url, String target, String features);

@JS()
extension type _WindowHandle._(JSObject _) implements JSObject {
  external JSObject get document;
  external void focus();
  external void print();
  external void close();
}

@JS()
extension type _Document._(JSObject _) implements JSObject {
  external void write(String html);
  external void close();
}

class PdfInvoiceService {
  static Future<void> generateAndPreviewPDF(Map<String, dynamic> order) async {
    try {
      final String orderId = order['orderId']?.toString() ?? 'Unknown';
      final String customerName =
          order['customerName']?.toString() ?? 'Unknown';
      final String customerPhone =
          order['customerPhone']?.toString() ?? 'Unknown';
      final String shippingAddress =
          order['shippingAddress']?.toString() ?? 'Not Provided';
      final String billingAddress =
          order['billingAddress']?.toString() ?? 'Not Provided';
      final List items =
          (order['items'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [];
      final double discount = (order['discount'] ?? 0).toDouble();
      final double totalAmount = (order['totalAmount'] ?? 0).toDouble();
      final String dateStr = DateFormat('MMM d, yyyy').format(DateTime.now());

      // Calculate subtotal
      double subtotal = 0;
      for (var item in items) {
        subtotal +=
            ((item['price'] ?? 0).toDouble() * (item['quantity'] ?? 1).toInt());
      }

      // Build HTML invoice
      final String html = _buildInvoiceHtml(
        orderId: orderId,
        customerName: customerName,
        customerPhone: customerPhone,
        shippingAddress: shippingAddress,
        billingAddress: billingAddress,
        items: items,
        subtotal: subtotal,
        discount: discount,
        totalAmount: totalAmount,
        dateStr: dateStr,
      );

      // ✅ Open in new tab and trigger browser print dialog
      final win = _openWindow('', '_blank', '') as _WindowHandle;
      final doc = win.document as _Document;
      doc.write(html);
      doc.close();
      win.focus();

      // Small delay so the browser renders the HTML before print dialog opens
      await Future.delayed(const Duration(milliseconds: 500));
      win.print();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate invoice: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  static String _buildInvoiceHtml({
    required String orderId,
    required String customerName,
    required String customerPhone,
    required String shippingAddress,
    required String billingAddress,
    required List items,
    required double subtotal,
    required double discount,
    required double totalAmount,
    required String dateStr,
  }) {
    // Build items rows
    final StringBuffer itemRows = StringBuffer();
    for (var item in items) {
      final qty = (item['quantity'] ?? 1).toInt();
      final price = (item['price'] ?? 0).toDouble();
      final amount = qty * price;
      itemRows.write('''
        <tr>
          <td>${item['name']?.toString() ?? 'Item'}</td>
          <td class="right">$qty</td>
          <td class="right">BDT ${price.toStringAsFixed(2)}</td>
          <td class="right">BDT ${amount.toStringAsFixed(2)}</td>
        </tr>
      ''');
    }


    final String addressToShow =
        (billingAddress != 'Not Provided' && billingAddress != 'Pending')
            ? billingAddress
            : shippingAddress;

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Invoice - $orderId</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      font-size: 13px;
      color: #1a1a1a;
      padding: 40px;
      max-width: 800px;
      margin: 0 auto;
    }

    .header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 40px;
    }

    .header h1 {
      font-size: 36px;
      font-weight: 700;
      color: #0A1F13;
    }

    .brand {
      font-size: 26px;
      font-weight: 700;
      color: #0A1F13;
    }

    .meta { margin-bottom: 30px; }
    .meta-row {
      display: flex;
      margin-bottom: 6px;
    }
    .meta-label {
      width: 130px;
      font-weight: 600;
      color: #555;
    }

    .addresses {
      display: flex;
      justify-content: space-between;
      margin-bottom: 40px;
    }

    .address-block { max-width: 280px; }
    .address-block .label {
      font-weight: 700;
      margin-bottom: 6px;
      color: #0A1F13;
    }
    .address-block p { 
      color: #444; 
      line-height: 1.6; 
    }

    .amount-due {
      font-size: 18px;
      font-weight: 700;
      margin-bottom: 24px;
      color: #0A1F13;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 0;
    }

    thead tr {
      border-bottom: 2px solid #0A1F13;
    }

    thead th {
      padding: 10px 8px;
      text-align: left;
      font-weight: 700;
      font-size: 12px;
      color: #0A1F13;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }

    tbody tr {
      border-bottom: 1px solid #eee;
    }

    tbody td {
      padding: 12px 8px;
      color: #333;
    }

    .right { text-align: right; }

    .totals {
      display: flex;
      justify-content: flex-end;
      margin-top: 16px;
    }

    .totals-box {
      width: 280px;
    }

    .total-row {
      display: flex;
      justify-content: space-between;
      padding: 6px 0;
      color: #444;
    }

    .total-row.bold {
      font-weight: 700;
      font-size: 15px;
      color: #0A1F13;
      border-top: 2px solid #0A1F13;
      margin-top: 6px;
      padding-top: 10px;
    }

    .divider {
      border: none;
      border-top: 1px solid #ddd;
      margin: 4px 0;
    }

    .footer {
      margin-top: 60px;
      display: flex;
      justify-content: space-between;
      color: #999;
      font-size: 11px;
      border-top: 1px solid #eee;
      padding-top: 16px;
    }

    @media print {
      body { padding: 20px; }
      @page { margin: 1cm; size: A4; }
    }
  </style>
</head>
<body>

  <!-- HEADER -->
  <div class="header">
    <h1>Invoice</h1>
    <div class="brand">FADHL</div>
  </div>

  <!-- META -->
  <div class="meta">
    <div class="meta-row">
      <span class="meta-label">Invoice number</span>
      <span>$orderId</span>
    </div>
    <div class="meta-row">
      <span class="meta-label">Date of issue</span>
      <span>$dateStr</span>
    </div>
    <div class="meta-row">
      <span class="meta-label">Date due</span>
      <span>$dateStr</span>
    </div>
  </div>

  <!-- ADDRESSES -->
  <div class="addresses">
    <div class="address-block">
      <div class="label">From</div>
      <p>FADHL E-Commerce</p>
      <p>Dhaka, Bangladesh</p>
      <p>support@fadhl.com</p>
    </div>
    <div class="address-block">
      <div class="label">Bill to</div>
      <p>$customerName</p>
      <p>$customerPhone</p>
      <p>$addressToShow</p>
    </div>
  </div>

  <!-- AMOUNT DUE -->
  <div class="amount-due">BDT ${totalAmount.toStringAsFixed(2)} due $dateStr</div>

  <!-- ITEMS TABLE -->
  <table>
    <thead>
      <tr>
        <th>Description</th>
        <th class="right">Qty</th>
        <th class="right">Unit price</th>
        <th class="right">Amount</th>
      </tr>
    </thead>
    <tbody>
      $itemRows
    </tbody>
  </table>

  <!-- TOTALS -->
  <div class="totals">
    <div class="totals-box">
      <div class="total-row">
        <span>Subtotal</span>
        <span>BDT ${subtotal.toStringAsFixed(2)}</span>
      </div>
      <div class="total-row">
        <span>Delivery Charge</span>
        <span>BDT 120.00</span>
      </div>
      ${discount > 0 ? '<div class="total-row"><span>Discount</span><span>- BDT ${discount.toStringAsFixed(2)}</span></div>' : ''}
      <div class="total-row bold">
        <span>Amount due</span>
        <span>BDT ${totalAmount.toStringAsFixed(2)}</span>
      </div>
    </div>
  </div>

  <!-- FOOTER -->
  <div class="footer">
    <span>Thank you for shopping with FADHL.</span>
    <span>Page 1 of 1</span>
  </div>

</body>
</html>
''';
  }
}