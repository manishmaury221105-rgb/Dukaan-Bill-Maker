import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/shop_profile.dart';
import '../models/bill_model.dart';
import '../utils/formatters.dart';
import 'file_downloader.dart';

class ShareService {
  /// Generate formatted text receipt for WhatsApp
  static String generateWhatsAppText({
    required ShopProfile shop,
    required BillModel bill,
  }) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln("🧾 *${shop.shopName.toUpperCase()}*");
    if (shop.ownerName.isNotEmpty) {
      buffer.writeln("👤 Owner: ${shop.ownerName}");
    }
    if (shop.phone.isNotEmpty) {
      buffer.writeln("📞 Mobile: +91 ${shop.phone}");
    }
    buffer.writeln("───────────────────");
    buffer.writeln("📋 *Bill No:* #${bill.billNumber}");
    buffer.writeln("📅 *Date:* ${Formatters.formatDateTime(bill.date)}");
    if (bill.customerName.isNotEmpty) {
      buffer.writeln("👤 *Customer:* ${bill.customerName}");
    }
    buffer.writeln("───────────────────");
    buffer.writeln("*ITEMS:*");

    int index = 1;
    for (final item in bill.items) {
      if (item.name.trim().isEmpty) continue;
      final qtyStr = Formatters.formatNumber(item.quantity);
      final rateStr = Formatters.formatCurrency(item.price);
      final totalStr = Formatters.formatCurrency(item.total);
      buffer.writeln("$index. *${item.name}*");
      buffer.writeln("   $qtyStr ${item.unit} × $rateStr = $totalStr");
      index++;
    }

    buffer.writeln("───────────────────");
    buffer.writeln("Subtotal: ${Formatters.formatCurrency(bill.subtotal)}");
    if (bill.discountAmount > 0) {
      buffer.writeln("Discount: -${Formatters.formatCurrency(bill.discountAmount)}");
    }
    buffer.writeln("💰 *GRAND TOTAL: ${Formatters.formatCurrency(bill.grandTotal)}*");
    buffer.writeln("───────────────────");
    buffer.writeln("🙏 *Thank You! Visit Again*");
    if (shop.upiId.isNotEmpty) {
      buffer.writeln("💳 *UPI Pay:* ${shop.upiId}");
    }
    buffer.writeln("✨ _Generated via Dukaan Bill Maker_");

    return buffer.toString();
  }

  /// Download and save PDF to device / trigger web browser download
  static Future<bool> downloadPdf({
    required Uint8List pdfBytes,
    required String billNumber,
    required String shopName,
  }) async {
    try {
      if (pdfBytes.isEmpty) {
        debugPrint('Warning: PDF bytes are empty!');
        return false;
      }
      final sanitizedShopName = shopName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final filename = '${sanitizedShopName}_Bill_$billNumber.pdf';

      return await FileDownloader.downloadPdf(pdfBytes, filename);
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
      return false;
    }
  }

  /// Share PDF file via standard system share sheet (WhatsApp, Drive, Email, etc.)
  static Future<void> sharePdf({
    required Uint8List pdfBytes,
    required String billNumber,
    required String shopName,
    String? customMessage,
  }) async {
    final sanitizedShopName = shopName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final filename = '${sanitizedShopName}_Bill_$billNumber.pdf';

    if (kIsWeb) {
      await FileDownloader.downloadPdf(pdfBytes, filename);
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$filename';
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes, flush: true);

    final xFile = XFile(
      filePath,
      mimeType: 'application/pdf',
      name: filename,
    );

    await SharePlus.instance.share(
      ShareParams(
        files: [xFile],
        text: customMessage ?? 'Dukaan Bill #$billNumber - $shopName',
      ),
    );
  }

  /// Direct WhatsApp launch with formatted message to a phone number or general share
  static Future<bool> sendWhatsAppMessage({
    String? phoneNumber,
    required String message,
  }) async {
    String cleanNumber = (phoneNumber ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNumber.length == 10) {
      cleanNumber = '91$cleanNumber';
    }

    final encodedMessage = Uri.encodeComponent(message);
    final String urlString = cleanNumber.isNotEmpty
        ? 'https://api.whatsapp.com/send?phone=$cleanNumber&text=$encodedMessage'
        : 'https://api.whatsapp.com/send?text=$encodedMessage';

    final whatsappUrl = Uri.parse(urlString);

    try {
      if (kIsWeb) {
        return await launchUrl(
          whatsappUrl,
          mode: LaunchMode.platformDefault,
          webOnlyWindowName: '_blank',
        );
      } else {
        if (await canLaunchUrl(whatsappUrl)) {
          return await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        } else {
          await SharePlus.instance.share(ShareParams(text: message));
          return true;
        }
      }
    } catch (e) {
      if (!kIsWeb) {
        await SharePlus.instance.share(ShareParams(text: message));
      }
      return false;
    }
  }
}
