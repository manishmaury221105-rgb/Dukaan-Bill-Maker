import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/shop_profile.dart';
import '../models/bill_model.dart';
import '../models/bill_item.dart';

class PdfService {
  /// Generate printable PDF document bytes
  static Future<Uint8List> generateInvoice({
    required ShopProfile shop,
    required BillModel bill,
  }) async {
    final pdf = pw.Document();

    // Primary Brand Color from Shop Theme
    final primaryColor = PdfColor.fromInt(shop.themeColorValue);
    const secondaryColor = PdfColor.fromInt(0xFF0F172A);
    const lightBg = PdfColor.fromInt(0xFFF8FAFC);
    const borderGray = PdfColor.fromInt(0xFFE2E8F0);
    const textGray = PdfColor.fromInt(0xFF64748B);

    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('hh:mm a');

    // Decode Logo if available
    pw.MemoryImage? logoImage;
    if (shop.logoBase64.isNotEmpty) {
      try {
        final decodedBytes = base64Decode(shop.logoBase64);
        logoImage = pw.MemoryImage(decodedBytes);
      } catch (_) {
        logoImage = null;
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ================= HEADER SECTION =================
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: lightBg,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                  border: pw.Border.all(color: borderGray, width: 1),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Shop Logo + Details
                    pw.Expanded(
                      flex: 3,
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (logoImage != null) ...[
                            pw.Container(
                              width: 54,
                              height: 54,
                              margin: const pw.EdgeInsets.only(right: 12),
                              decoration: pw.BoxDecoration(
                                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                                border: pw.Border.all(color: borderGray),
                              ),
                              child: pw.ClipRRect(
                                horizontalRadius: 8,
                                verticalRadius: 8,
                                child: pw.Image(logoImage, fit: pw.BoxFit.cover),
                              ),
                            ),
                          ],
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  shop.shopName.isNotEmpty ? shop.shopName.toUpperCase() : 'DUKAAN BILL',
                                  style: pw.TextStyle(
                                    fontSize: 20,
                                    fontWeight: pw.FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                if (shop.ownerName.isNotEmpty) ...[
                                  pw.SizedBox(height: 3),
                                  pw.Text(
                                    'Malik: ${shop.ownerName}',
                                    style: pw.TextStyle(
                                      fontSize: 11,
                                      fontWeight: pw.FontWeight.bold,
                                      color: secondaryColor,
                                    ),
                                  ),
                                ],
                                if (shop.phone.isNotEmpty) ...[
                                  pw.SizedBox(height: 2),
                                  pw.Text(
                                    'Mobile: +91 ${shop.phone}',
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                      color: textGray,
                                    ),
                                  ),
                                ],
                                if (shop.address.isNotEmpty) ...[
                                  pw.SizedBox(height: 2),
                                  pw.Text(
                                    'Address: ${shop.address}',
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                      color: textGray,
                                    ),
                                  ),
                                ],
                                if (shop.gstNumber.isNotEmpty) ...[
                                  pw.SizedBox(height: 2),
                                  pw.Text(
                                    'GSTIN: ${shop.gstNumber}',
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                      color: textGray,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bill Meta Details (Right Side)
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                          border: pw.Border.all(color: borderGray, width: 1),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: pw.BoxDecoration(
                                color: primaryColor,
                                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                              ),
                              child: pw.Text(
                                'CASH MEMO / BILL',
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white,
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 6),
                            pw.Text(
                              'Bill No: #${bill.billNumber}',
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: secondaryColor,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              'Date: ${dateFormat.format(bill.date)}',
                              style: const pw.TextStyle(
                                fontSize: 10,
                                color: textGray,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              'Time: ${timeFormat.format(bill.date)}',
                              style: const pw.TextStyle(
                                fontSize: 10,
                                color: textGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Customer Details (if provided)
              if (bill.customerName.isNotEmpty || bill.customerPhone.isNotEmpty) ...[
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    border: pw.Border.all(color: borderGray, width: 1),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Text(
                        'Grahak (Customer): ',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: secondaryColor),
                      ),
                      pw.Text(
                        bill.customerName.isNotEmpty ? bill.customerName : 'Cash Customer',
                        style: const pw.TextStyle(fontSize: 10, color: secondaryColor),
                      ),
                      if (bill.customerPhone.isNotEmpty) ...[
                        pw.Spacer(),
                        pw.Text(
                          'Phone: +91 ${bill.customerPhone}',
                          style: const pw.TextStyle(fontSize: 10, color: textGray),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              pw.SizedBox(height: 16),

              // ================= ITEMS TABLE =================
              pw.Expanded(
                child: _buildItemsTable(bill.items, primaryColor, secondaryColor, borderGray, lightBg),
              ),

              pw.SizedBox(height: 16),

              // ================= TOTALS & FOOTER SECTION =================
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  // Left side: UPI / Notes / Thank You
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (shop.upiId.isNotEmpty) ...[
                          pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            decoration: pw.BoxDecoration(
                              color: lightBg,
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                              border: pw.Border.all(color: borderGray),
                            ),
                            child: pw.Row(
                              mainAxisSize: pw.MainAxisSize.min,
                              children: [
                                pw.BarcodeWidget(
                                  barcode: pw.Barcode.qrCode(),
                                  data: 'upi://pay?pa=${shop.upiId}&pn=${Uri.encodeComponent(shop.shopName)}&am=${bill.grandTotal.toStringAsFixed(2)}&cu=INR',
                                  width: 50,
                                  height: 50,
                                ),
                                pw.SizedBox(width: 10),
                                pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      'Scan & Pay with UPI',
                                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: secondaryColor),
                                    ),
                                    pw.Text(
                                      shop.upiId,
                                      style: const pw.TextStyle(fontSize: 8, color: textGray),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 8),
                        ],
                        // Thank you box
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: pw.BoxDecoration(
                            color: const PdfColor.fromInt(0xFFE8F8F0),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Dhanyawad! Phir Aaiye - Thank You! Visit Again',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                'Goods once sold will be exchanged as per shop policy.',
                                style: const pw.TextStyle(fontSize: 7, color: textGray),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(width: 20),

                  // Right side: Calculation Breakdown
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: lightBg,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                        border: pw.Border.all(color: borderGray, width: 1),
                      ),
                      child: pw.Column(
                        children: [
                          _buildSummaryRow('Subtotal:', 'Rs. ${bill.subtotal.toStringAsFixed(2)}', secondaryColor),
                          if (bill.discountAmount > 0) ...[
                            pw.SizedBox(height: 4),
                            _buildSummaryRow(
                              'Discount (${bill.discountType == 'percent' ? '${bill.discount}%' : 'Flat'}):',
                              '- Rs. ${bill.discountAmount.toStringAsFixed(2)}',
                              const PdfColor.fromInt(0xFFEF4444),
                            ),
                          ],
                          pw.Divider(color: borderGray, height: 12),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: pw.BoxDecoration(
                              color: primaryColor,
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                            ),
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  'Grand Total:',
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.white,
                                  ),
                                ),
                                pw.Text(
                                  'Rs. ${bill.grandTotal.toStringAsFixed(2)}',
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 12),

              // Bottom footer watermark / signature
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Generated via Dukaan Bill Maker App',
                    style: const pw.TextStyle(fontSize: 7, color: textGray),
                  ),
                  pw.Text(
                    'Authorised Signatory',
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: secondaryColor),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildItemsTable(
    List<BillItem> items,
    PdfColor primaryColor,
    PdfColor secondaryColor,
    PdfColor borderGray,
    PdfColor lightBg,
  ) {
    final validItems = items.where((i) => i.name.trim().isNotEmpty).toList();

    return pw.Table(
      border: pw.TableBorder.all(color: borderGray, width: 0.8),
      columnWidths: const {
        0: pw.FlexColumnWidth(0.8), // Sr.
        1: pw.FlexColumnWidth(3.5), // Saman Ka Naam
        2: pw.FlexColumnWidth(1.2), // Unit
        3: pw.FlexColumnWidth(1.2), // Qty
        4: pw.FlexColumnWidth(1.5), // Rate
        5: pw.FlexColumnWidth(1.8), // Total
      },
      children: [
        // Table Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: primaryColor),
          children: [
            _buildTableHeaderCell('Sr.'),
            _buildTableHeaderCell('Saman (Item Description)', align: pw.TextAlign.left),
            _buildTableHeaderCell('Unit'),
            _buildTableHeaderCell('Qty'),
            _buildTableHeaderCell('Rate (Rs.)'),
            _buildTableHeaderCell('Total (Rs.)', align: pw.TextAlign.right),
          ],
        ),
        // Table Rows
        ...List.generate(validItems.length, (index) {
          final item = validItems[index];
          final isEven = index % 2 == 0;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.white : lightBg,
            ),
            children: [
              _buildTableCell('${index + 1}', align: pw.TextAlign.center),
              _buildTableCell(item.name, align: pw.TextAlign.left, isBold: true),
              _buildTableCell(item.unit, align: pw.TextAlign.center),
              _buildTableCell(item.quantity.toString().replaceAll(RegExp(r'\.0$'), ''), align: pw.TextAlign.center),
              _buildTableCell(item.price.toStringAsFixed(2), align: pw.TextAlign.right),
              _buildTableCell(item.total.toStringAsFixed(2), align: pw.TextAlign.right, isBold: true),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTableHeaderCell(String text, {pw.TextAlign align = pw.TextAlign.center}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.center,
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: const PdfColor.fromInt(0xFF0F172A),
        ),
      ),
    );
  }

  static pw.Widget _buildSummaryRow(String label, String value, PdfColor color) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10, color: const PdfColor.fromInt(0xFF64748B)),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
