import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/bill_model.dart';
import '../providers/billing_provider.dart';
import '../providers/history_provider.dart';
import '../providers/shop_provider.dart';
import '../services/pdf_service.dart';
import '../services/share_service.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';

class PdfPreviewScreen extends StatefulWidget {
  final BillModel bill;

  const PdfPreviewScreen({super.key, required this.bill});

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  Uint8List? _pdfBytes;
  bool _isGenerating = true;
  bool _isSharing = false;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _generateAndSavePdf();
  }

  Future<void> _generateAndSavePdf() async {
    final shop = Provider.of<ShopProvider>(context, listen: false).profile;
    final history = Provider.of<HistoryProvider>(context, listen: false);

    // 1. Generate PDF Bytes
    final bytes = await PdfService.generateInvoice(
      shop: shop,
      bill: widget.bill,
    );

    // 2. Automatically save bill to history
    await history.saveBill(widget.bill);

    if (mounted) {
      setState(() {
        _pdfBytes = bytes;
        _isGenerating = false;
      });
    }
  }

  Future<void> _handleWhatsAppShare() async {
    setState(() => _isSharing = true);

    final shop = Provider.of<ShopProvider>(context, listen: false).profile;
    final textMessage = ShareService.generateWhatsAppText(
      shop: shop,
      bill: widget.bill,
    );

    await ShareService.sendWhatsAppMessage(
      phoneNumber: widget.bill.customerPhone.isNotEmpty ? widget.bill.customerPhone : null,
      message: textMessage,
    );

    if (mounted) {
      setState(() => _isSharing = false);
    }
  }

  Future<void> _handleDownloadPdf() async {
    if (_pdfBytes == null || _pdfBytes!.isEmpty) return;
    setState(() => _isDownloading = true);

    final shop = Provider.of<ShopProvider>(context, listen: false).profile;
    final success = await ShareService.downloadPdf(
      pdfBytes: _pdfBytes!,
      billNumber: widget.bill.billNumber,
      shopName: shop.shopName,
    );

    if (mounted) {
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(success ? Icons.check_circle_outline : Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  success
                      ? 'PDF Bill #${widget.bill.billNumber} Download Ho Gaya!'
                      : 'Download fail ho gaya. Kripya dobara try karein.',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: success ? AppColors.primary : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handlePrint() async {
    if (_pdfBytes == null) return;
    await Printing.layoutPdf(
      name: 'Bill_${widget.bill.billNumber}',
      onLayout: (format) async => Uint8List.fromList(_pdfBytes!),
    );
  }

  Future<void> _handleGeneralShare() async {
    if (_pdfBytes == null) return;
    final shop = Provider.of<ShopProvider>(context, listen: false).profile;
    await ShareService.sharePdf(
      pdfBytes: _pdfBytes!,
      billNumber: widget.bill.billNumber,
      shopName: shop.shopName,
    );
  }

  void _startNewBill() {
    final billing = Provider.of<BillingProvider>(context, listen: false);
    billing.initNewBill();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context);
    final isDark = shopProvider.isDarkMode;
    final surfaceColor = Theme.of(context).cardColor;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final primaryColor = shopProvider.primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Bill #${widget.bill.billNumber} PDF'),
        backgroundColor: surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _handleGeneralShare,
            tooltip: 'Share PDF',
            icon: Icon(Icons.share_outlined, color: textPrimary),
          ),
          IconButton(
            onPressed: _handlePrint,
            tooltip: 'Print Invoice',
            icon: Icon(Icons.print_outlined, color: textPrimary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isGenerating
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bill PDF Ban Rahi Hai...',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // PDF Viewer Card
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: PdfPreview(
                      build: (format) => Uint8List.fromList(_pdfBytes!),
                      useActions: false, // Hides top action bar
                      canChangeOrientation: false,
                      canChangePageFormat: false,
                      canDebug: false,
                      maxPageWidth: 700,
                      loadingWidget: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      ),
                    ),
                  ),
                ),

                // ================= BOTTOM ACTIONS =================
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Row 1: [Download PDF] & [Share on WhatsApp]
                        Row(
                          children: [
                            // Button 1: Download PDF
                            Expanded(
                              child: CustomButton(
                                text: 'Download PDF',
                                icon: Icons.download_rounded,
                                type: ButtonType.secondary,
                                height: 50,
                                fontSize: 14,
                                isLoading: _isDownloading,
                                onPressed: _handleDownloadPdf,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Button 2: Share on WhatsApp
                            Expanded(
                              child: CustomButton(
                                text: 'WhatsApp Share',
                                iconWidget: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 20),
                                type: ButtonType.whatsapp,
                                height: 50,
                                fontSize: 14,
                                isLoading: _isSharing,
                                onPressed: _handleWhatsAppShare,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Button 3: [Naya Bill Banao (New Bill)]
                        SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: _startNewBill,
                            icon: Icon(Icons.add_circle_outline_rounded, color: primaryColor, size: 20),
                            label: Text(
                              '+ Naya Bill Banayein (New Bill)',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: surfaceColor,
                              side: BorderSide(color: primaryColor, width: 1.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
