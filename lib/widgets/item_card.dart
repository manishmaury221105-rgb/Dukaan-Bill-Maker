import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/bill_item.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class ItemCard extends StatefulWidget {
  final int index;
  final BillItem item;
  final VoidCallback onDelete;
  final void Function(String name) onNameChanged;
  final void Function(double price) onPriceChanged;
  final void Function(double quantity) onQuantityChanged;
  final void Function(String unit) onUnitChanged;
  final VoidCallback onIncrementQty;
  final VoidCallback onDecrementQty;

  const ItemCard({
    super.key,
    required this.index,
    required this.item,
    required this.onDelete,
    required this.onNameChanged,
    required this.onPriceChanged,
    required this.onQuantityChanged,
    required this.onUnitChanged,
    required this.onIncrementQty,
    required this.onDecrementQty,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _priceController = TextEditingController(
      text: widget.item.price > 0 ? widget.item.price.toString().replaceAll(RegExp(r'\.0$'), '') : '',
    );
    _qtyController = TextEditingController(
      text: widget.item.quantity.toString().replaceAll(RegExp(r'\.0$'), ''),
    );
  }

  @override
  void didUpdateWidget(covariant ItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.name != widget.item.name && _nameController.text != widget.item.name) {
      _nameController.text = widget.item.name;
    }
    
    final priceStr = widget.item.price > 0 ? widget.item.price.toString().replaceAll(RegExp(r'\.0$'), '') : '';
    if (oldWidget.item.price != widget.item.price && _priceController.text != priceStr) {
      _priceController.text = priceStr;
    }

    final qtyStr = widget.item.quantity.toString().replaceAll(RegExp(r'\.0$'), '');
    if (oldWidget.item.quantity != widget.item.quantity && _qtyController.text != qtyStr) {
      _qtyController.text = qtyStr;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rowTotal = widget.item.total;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = Theme.of(context).cardColor;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Item Index Badge, Title & Delete Icon
            Row(
              children: [
                // Item Number Badge
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '#${widget.index + 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Saman Details',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const Spacer(),
                // Delete Button
                InkWell(
                  onTap: widget.onDelete,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF450A0A) : AppColors.dangerLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.danger,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Row 2: Saman Ka Naam (Autocomplete or TextField)
            TextFormField(
              controller: _nameController,
              onChanged: widget.onNameChanged,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Saman Ka Naam (e.g., Chawal, Cheeni)',
                hintStyle: GoogleFonts.poppins(
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                  fontSize: 13,
                ),
                prefixIcon: Icon(Icons.shopping_bag_outlined, color: primaryColor, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                isDense: true,
              ),
            ),

            const SizedBox(height: 10),

            // Row 3: Price, Qty, Unit
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price (Rate)
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rate (Price)',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        onChanged: (val) {
                          final p = double.tryParse(val) ?? 0.0;
                          widget.onPriceChanged(p);
                        },
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixText: '₹ ',
                          prefixStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Quantity with Stepper
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity (Qty)',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _qtyController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
                        ],
                        onChanged: (val) {
                          final q = double.tryParse(val) ?? 1.0;
                          widget.onQuantityChanged(q);
                        },
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Unit Dropdown
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unit',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 1.2),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: AppConstants.unitOptions.contains(widget.item.unit)
                                ? widget.item.unit
                                : AppConstants.unitOptions.first,
                            isExpanded: true,
                            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                            icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: textSecondary),
                            items: AppConstants.unitOptions.map((unit) {
                              return DropdownMenuItem<String>(
                                value: unit,
                                child: Text(
                                  unit,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (newUnit) {
                              if (newUnit != null) {
                                widget.onUnitChanged(newUnit);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Divider(color: borderColor, height: 1),
            const SizedBox(height: 8),

            // Row 4: Calculation Row Total Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Row Total: ${Formatters.formatNumber(widget.item.quantity)} ${widget.item.unit} × ${Formatters.formatCurrency(widget.item.price)}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    Formatters.formatCurrency(rowTotal, showDecimals: true),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
