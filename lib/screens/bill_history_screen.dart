import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/bill_model.dart';
import '../providers/billing_provider.dart';
import '../providers/history_provider.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/stat_card.dart';
import 'pdf_preview_screen.dart';

class BillHistoryScreen extends StatelessWidget {
  const BillHistoryScreen({super.key});

  void _openBillOptions(BuildContext context, BillModel bill) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bill #${bill.billNumber}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  Formatters.formatCurrency(bill.grandTotal),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${Formatters.formatDateTime(bill.date)} • ${bill.totalItemCount} ${bill.totalItemCount == 1 ? 'Item' : 'Items'}',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Option 1: View / Share PDF
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
              ),
              title: Text('View / Print / Share PDF', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text('View, print or share on WhatsApp', style: GoogleFonts.poppins(fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PdfPreviewScreen(bill: bill),
                  ),
                );
              },
            ),

            // Option 2: Edit / Re-use Bill
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_rounded, color: AppColors.accent),
              ),
              title: Text('Edit / Duplicate Bill', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text('Modify items and create a new bill', style: GoogleFonts.poppins(fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                final billing = Provider.of<BillingProvider>(context, listen: false);
                billing.loadBill(bill);
                Navigator.pop(context); // Go back to BillingHomeScreen
              },
            ),

            // Option 3: Delete Bill
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
              ),
              title: Text('Delete Bill', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.danger)),
              subtitle: Text('Permanently delete from history', style: GoogleFonts.poppins(fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteBill(context, bill.id, bill.billNumber);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteBill(BuildContext context, String id, String billNo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Bill #$billNo?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete this bill?', style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<HistoryProvider>(context, listen: false).deleteBill(id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Bill #$billNo deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = Provider.of<HistoryProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).cardColor;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Bill History & Sales'),
        backgroundColor: surfaceColor,
        elevation: 0,
      ),
      body: history.isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          : Column(
              children: [
                // Top Analytics Row
                Container(
                  color: surfaceColor,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: "Today's Sales",
                              value: Formatters.formatCurrency(history.todaySales),
                              subtitle: '${history.todayBillsCount} ${history.todayBillsCount == 1 ? 'bill today' : 'bills today'}',
                              icon: Icons.currency_rupee_rounded,
                              iconColor: primaryColor,
                              iconBgColor: AppColors.primaryLight,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              title: "Total Bills",
                              value: '${history.totalBillsCount}',
                              subtitle: 'Lifetime Bills',
                              icon: Icons.receipt_long_rounded,
                              iconColor: AppColors.secondary,
                              iconBgColor: const Color(0xFFE0F2FE),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Search Input
                      TextFormField(
                        onChanged: history.setSearchQuery,
                        style: GoogleFonts.poppins(fontSize: 14, color: textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search by bill no, item, customer...',
                          prefixIcon: Icon(Icons.search_rounded, color: textSecondary, size: 20),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: borderColor),

                // Bills List
                Expanded(
                  child: history.bills.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.receipt_long_outlined,
                                  size: 48,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                history.searchQuery.isNotEmpty
                                    ? 'No bills found'
                                    : 'No bills created yet',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Create and save your first bill',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: history.bills.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final bill = history.bills[index];
                            return InkWell(
                              onTap: () => _openBillOptions(context, bill),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderColor, width: 1.2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Bill No Tag
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            'BILL',
                                            style: GoogleFonts.poppins(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? Colors.white : primaryColor,
                                            ),
                                          ),
                                          Text(
                                            '#${bill.billNumber}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: isDark ? Colors.white : primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Center Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bill.customerName.isNotEmpty
                                                ? bill.customerName
                                                : '${bill.totalItemCount} ${bill.totalItemCount == 1 ? 'Item' : 'Items'}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${Formatters.formatDateTime(bill.date)}${bill.customerPhone.isNotEmpty ? ' • +91 ${bill.customerPhone}' : ''}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Right: Grand Total & Arrow
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          Formatters.formatCurrency(bill.grandTotal, showDecimals: true),
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: primaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Options',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: textSecondary,
                                              ),
                                            ),
                                            Icon(
                                              Icons.chevron_right_rounded,
                                              size: 16,
                                              color: textSecondary,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
