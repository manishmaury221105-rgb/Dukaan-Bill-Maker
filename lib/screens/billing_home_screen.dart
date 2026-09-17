import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/bill_model.dart';
import '../providers/billing_provider.dart';
import '../providers/shop_provider.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/bill_preview_dialog.dart';
import '../widgets/item_card.dart';
import 'bill_history_screen.dart';
import 'onboarding_screen.dart';
import 'pdf_preview_screen.dart';

class BillingHomeScreen extends StatefulWidget {
  const BillingHomeScreen({super.key});

  @override
  State<BillingHomeScreen> createState() => _BillingHomeScreenState();
}

class _BillingHomeScreenState extends State<BillingHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  bool _showCustomerFields = false;

  @override
  void initState() {
    super.initState();
    final billing = Provider.of<BillingProvider>(context, listen: false);
    if (billing.discount > 0) {
      _discountController.text = billing.discount.toString().replaceAll(RegExp(r'\.0$'), '');
    }
    _customerNameController.text = billing.customerName;
    _customerPhoneController.text = billing.customerPhone;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _discountController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openBillPreview() {
    final billing = Provider.of<BillingProvider>(context, listen: false);
    final shop = Provider.of<ShopProvider>(context, listen: false).profile;

    if (billing.validItemCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kripya pehle kam se kam 1 saman ka naam dalein'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final bill = billing.toBillModel();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BillPreviewModal(
        shop: shop,
        bill: bill,
        onPdfGenerate: () => _navigateToPdfScreen(bill),
      ),
    );
  }

  void _navigateToPdfScreen(BillModel bill) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfPreviewScreen(bill: bill),
      ),
    );
  }

  void _confirmNewBill() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Naya Bill Shuru Karein?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text(
          'Kya aap vartaman bill clear karke naya bill banana chahte hain?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Nahi', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final billing = Provider.of<BillingProvider>(context, listen: false);
              billing.initNewBill();
              _discountController.clear();
              _customerNameController.clear();
              _customerPhoneController.clear();
              setState(() => _showCustomerFields = false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(100, 42),
            ),
            child: Text('Haan, Naya Bill', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context);
    final billingProvider = Provider.of<BillingProvider>(context);
    final shop = shopProvider.profile;
    final primaryColor = shopProvider.primaryColor;
    final isDark = shopProvider.isDarkMode;
    final surfaceColor = Theme.of(context).cardColor;
    final textPrimaryColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            if (shop.logoBase64.isNotEmpty) ...[
              Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.memory(
                    base64Decode(shop.logoBase64),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          shop.shopName.isNotEmpty ? shop.shopName : 'Dukaan Bill Maker',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textPrimaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${billingProvider.billNumber}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (shop.ownerName.isNotEmpty)
                    Text(
                      'Malik: ${shop.ownerName} • ${Formatters.formatDate(billingProvider.date)}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: textSecondaryColor,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Dark Mode Toggle Button
          IconButton(
            onPressed: () => shopProvider.toggleDarkMode(),
            tooltip: isDark ? 'Light Mode Karein' : 'Dark Mode Karein',
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => RotationTransition(turns: anim, child: ScaleTransition(scale: anim, child: child)),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey<bool>(isDark),
                color: isDark ? Colors.amber : AppColors.textSecondary,
              ),
            ),
          ),
          // Clear / New Bill Action
          IconButton(
            onPressed: _confirmNewBill,
            tooltip: 'Naya Bill',
            icon: Icon(Icons.refresh_rounded, color: textSecondaryColor),
          ),
          // History Action
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BillHistoryScreen()),
              );
            },
            tooltip: 'Bill History',
            icon: Icon(Icons.history_rounded, color: primaryColor),
          ),
          // Settings Action
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OnboardingScreen(isEditMode: true)),
              );
            },
            tooltip: 'Shop Settings',
            icon: Icon(Icons.settings_outlined, color: textSecondaryColor),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // Optional Customer Details Accordion Bar
          Container(
            color: surfaceColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                InkWell(
                  onTap: () => setState(() => _showCustomerFields = !_showCustomerFields),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 18,
                          color: _showCustomerFields ? primaryColor : textSecondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _showCustomerFields ? 'Grahak Details Chhupayein' : '+ Grahak Ki Jankari Jodein (Optional)',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _showCustomerFields ? primaryColor : textSecondaryColor,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _showCustomerFields ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: textSecondaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showCustomerFields) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _customerNameController,
                          onChanged: (val) => billingProvider.setCustomerInfo(name: val),
                          textCapitalization: TextCapitalization.words,
                          style: GoogleFonts.poppins(fontSize: 13, color: textPrimaryColor),
                          decoration: InputDecoration(
                            hintText: 'Grahak Ka Naam',
                            prefixIcon: Icon(Icons.badge_outlined, size: 16, color: textSecondaryColor),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _customerPhoneController,
                          onChanged: (val) => billingProvider.setCustomerInfo(phone: val),
                          keyboardType: TextInputType.phone,
                          style: GoogleFonts.poppins(fontSize: 13, color: textPrimaryColor),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: InputDecoration(
                            hintText: 'WhatsApp / Mobile',
                            prefixIcon: Icon(Icons.phone_iphone_rounded, size: 16, color: textSecondaryColor),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          Divider(height: 1, color: borderColor),

          // Main Form List: Items Cards
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                // Header row of items section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saman Ki Suchi (${billingProvider.items.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimaryColor,
                      ),
                    ),
                    Text(
                      'Rate × Qty',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Dynamic Items List
                ...List.generate(billingProvider.items.length, (index) {
                  final item = billingProvider.items[index];
                  return ItemCard(
                    key: ValueKey(item.id),
                    index: index,
                    item: item,
                    onNameChanged: (name) => billingProvider.updateItemName(index, name),
                    onPriceChanged: (price) => billingProvider.updateItemPrice(index, price),
                    onQuantityChanged: (qty) => billingProvider.updateItemQuantity(index, qty),
                    onUnitChanged: (unit) => billingProvider.updateItemUnit(index, unit),
                    onIncrementQty: () => billingProvider.incrementQuantity(index),
                    onDecrementQty: () => billingProvider.decrementQuantity(index),
                    onDelete: () => billingProvider.removeItem(index),
                  );
                }),

                const SizedBox(height: 12),

                // [+ Add Saman] Button
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      billingProvider.addItem();
                      _scrollToBottom();
                    },
                    icon: Icon(Icons.add_circle_outline_rounded, size: 22, color: primaryColor),
                    label: Text(
                      '+ Add Saman (नया सामान जोड़ें)',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
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

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),

      // ================= BOTTOM STICKY SECTION =================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Subtotal & Discount Row
              Row(
                children: [
                  // Subtotal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subtotal:',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textSecondaryColor,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(billingProvider.subtotal),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Discount Input Field
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Discount (छूट):',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: textSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            SizedBox(
                              width: 110,
                              height: 38,
                              child: TextFormField(
                                controller: _discountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                ],
                                onChanged: (val) {
                                  final d = double.tryParse(val) ?? 0.0;
                                  billingProvider.setDiscount(d);
                                },
                                textAlign: TextAlign.right,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.danger,
                                ),
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  prefixText: '₹ ',
                                  prefixStyle: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.danger,
                                    fontSize: 12,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Divider(color: borderColor, height: 1),
              const SizedBox(height: 8),

              // Grand Total in BIG BOLD PRIMARY THEME COLOR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grand Total',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textSecondaryColor,
                        ),
                      ),
                      Text(
                        '(${billingProvider.validItemCount} Saman)',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    Formatters.formatCurrency(billingProvider.grandTotal, showDecimals: true),
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: primaryColor, // Dynamic Theme Brand Color
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 2 Big Buttons: [Preview Bill] and [PDF Banao]
              Row(
                children: [
                  // Button 1: [Preview Bill]
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _openBillPreview,
                        icon: Icon(Icons.remove_red_eye_outlined, size: 20, color: primaryColor),
                        label: Text(
                          'Preview Bill',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryColor, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Button 2: [PDF Banao]
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (billingProvider.validItemCount == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Kripya pehle kam se kam 1 saman dalein'),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                            return;
                          }
                          final bill = billingProvider.toBillModel();
                          _navigateToPdfScreen(bill);
                        },
                        icon: const Icon(Icons.picture_as_pdf_rounded, size: 20, color: Colors.white),
                        label: Text(
                          'PDF Banao',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          elevation: 2,
                          shadowColor: primaryColor.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
