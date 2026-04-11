import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfInvoiceService {
  static Future<void> generateAndPreviewPDF(Map<String, dynamic> order) async {
    try {
      // 1. Prepare data instantly (Takes 1 millisecond, NO freezing)
      Uint8List? logoData;
      try {
        final ByteData image = await rootBundle.load('assets/logo.webp');
        logoData = image.buffer.asUint8List();
      } catch (e) {
        debugPrint('Logo skipped: Assets misconfigured.');
      }

      final Map<String, dynamic> pdfData = {
        'logoBytes': logoData,
        'orderId': order['orderId']?.toString() ?? 'Unknown',
        'customerName': order['customerName']?.toString() ?? 'Unknown',
        'customerPhone': order['customerPhone']?.toString() ?? 'Unknown',
        'shippingAddress':
            order['shippingAddress']?.toString() ?? 'Not Provided',
        'billingAddress': order['billingAddress']?.toString() ?? 'Not Provided',
        'items':
            (order['items'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e))
                .toList() ??
            [],
        'discount': (order['discount'] ?? 0).toDouble(),
        'totalAmount': (order['totalAmount'] ?? 0).toDouble(),
        'dateStr': DateFormat('MMM d, yyyy').format(DateTime.now()),
      };

      final String cleanCustomerName = pdfData['customerName'].replaceAll(
        RegExp(r'[\\/]'),
        '_',
      );

      // 2. 🔥 BEST PRACTICE: Open the Print Dialog IMMEDIATELY.
      // Do NOT await the PDF generation before opening the dialog.
      // This delegates the "frozen" waiting time to the Browser's native print screen.
      await Printing.layoutPdf(
        name: 'Invoice_$cleanCustomerName',
        onLayout: (PdfPageFormat format) async {
          // The heavy processing only starts AFTER the native browser dialog opens.
          // Chrome/Safari will show their native "Loading Preview..." spinner during the 2-3 sec freeze.
          return await _buildPdfDocument(pdfData, format);
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to prepare invoice: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}

// 🔥 Removed the 'compute' isolate entirely since it doesn't work on the web anyway.
// Passed the 'format' parameter so the PDF natively adapts to the printer's page size (A4, Letter, etc).
Future<Uint8List> _buildPdfDocument(
  Map<String, dynamic> data,
  PdfPageFormat format,
) async {
  final pdf = pw.Document();

  final Uint8List? logoData = data['logoBytes'];
  final String orderId = data['orderId'];
  final String customerName = data['customerName'];
  final String customerPhone = data['customerPhone'];
  final String shippingAddress = data['shippingAddress'];
  final String billingAddress = data['billingAddress'];
  final List items = data['items'];
  final double discount = data['discount'];
  final double totalAmount = data['totalAmount'];
  final String dateStr = data['dateStr'];

  double subtotal = 0;
  for (var item in items) {
    double price = (item['price'] ?? 0).toDouble();
    int qty = (item['quantity'] ?? 1).toInt();
    subtotal += (price * qty);
  }

  final pw.TextStyle normal = const pw.TextStyle(
    fontSize: 10,
    color: PdfColors.black,
  );
  final pw.TextStyle bold = pw.TextStyle(
    fontSize: 10,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  pw.Widget buildMeta(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.Container(width: 100, child: pw.Text(label, style: bold)),
          pw.Text(value, style: normal),
        ],
      ),
    );
  }

  pw.Widget buildTotalRow(String label, String value, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text(label, style: style), pw.Text(value, style: style)],
      ),
    );
  }

  pdf.addPage(
    pw.Page(
      pageFormat: format, // Adapts seamlessly to user's printer settings
      margin: const pw.EdgeInsets.all(50),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // 1. HEADER
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Invoice',
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (logoData != null)
                  pw.Image(pw.MemoryImage(logoData), height: 40)
                else
                  pw.Text(
                    'FADHL',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
              ],
            ),
            pw.SizedBox(height: 30),

            // 2. META DETAILS
            buildMeta('Invoice number', orderId),
            buildMeta('Date of issue', dateStr),
            buildMeta('Date due', dateStr),
            pw.SizedBox(height: 30),

            // 3. ADDRESSES
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('FADHL E-Commerce', style: bold),
                    pw.Text('Dhaka, Bangladesh', style: normal),
                    pw.Text('support@fadhl.com', style: normal),
                  ],
                ),

                pw.Container(
                  width: 250,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Bill to', style: bold),
                      pw.Text(customerName, style: normal),
                      pw.Text(customerPhone, style: normal),
                      if (billingAddress != 'Not Provided' &&
                          billingAddress != 'Pending')
                        pw.Text(billingAddress, style: normal)
                      else if (shippingAddress != 'Not Provided' &&
                          shippingAddress != 'Pending')
                        pw.Text(shippingAddress, style: normal),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 40),

            // 4. AMOUNT DUE HIGHLIGHT
            pw.Text(
              'BDT ${totalAmount.toStringAsFixed(2)} due $dateStr',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),

            // 5. TABLE
            pw.TableHelper.fromTextArray(
              headers: ['Description', 'Qty', 'Unit price', 'Amount'],
              border: null,
              headerStyle: bold,
              cellStyle: normal,
              headerDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                ),
              ),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerRight,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
              },
              data:
                  items.map((item) {
                    final qty = (item['quantity'] ?? 1).toInt();
                    final price = (item['price'] ?? 0).toDouble();
                    return [
                      item['name']?.toString() ?? 'Item',
                      qty.toString(),
                      'BDT ${price.toStringAsFixed(2)}',
                      'BDT ${(qty * price).toStringAsFixed(2)}',
                    ];
                  }).toList(),
            ),
            pw.Divider(color: PdfColors.black, thickness: 1),

            // 6. TOTALS
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 250,
                child: pw.Column(
                  children: [
                    pw.SizedBox(height: 10),
                    buildTotalRow(
                      'Subtotal',
                      'BDT ${subtotal.toStringAsFixed(2)}',
                      normal,
                    ),
                    buildTotalRow('Delivery Charge', 'BDT 120.00', normal),
                    if (discount > 0)
                      buildTotalRow(
                        'Discount',
                        '- BDT ${discount.toStringAsFixed(2)}',
                        normal,
                      ),
                    pw.Divider(color: PdfColors.grey300),
                    buildTotalRow(
                      'Amount due',
                      'BDT ${totalAmount.toStringAsFixed(2)} BDT',
                      bold,
                    ),
                  ],
                ),
              ),
            ),

            pw.Spacer(),

            // 7. FOOTER
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Thank you for shopping with FADHL.',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
                pw.Text(
                  'Page 1 of 1',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );

  return await pdf.save();
}
