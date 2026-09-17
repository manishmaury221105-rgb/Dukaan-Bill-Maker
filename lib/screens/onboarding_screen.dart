import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/shop_profile.dart';
import '../providers/shop_provider.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'billing_home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isEditMode;

  const OnboardingScreen({super.key, this.isEditMode = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _shopNameController;
  late TextEditingController _ownerNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _upiIdController;
  late TextEditingController _gstController;

  String _logoBase64 = '';
  int _selectedThemeColor = 0xFF00A859;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final currentProfile = Provider.of<ShopProvider>(context, listen: false).profile;
    _shopNameController = TextEditingController(text: currentProfile.shopName);
    _ownerNameController = TextEditingController(text: currentProfile.ownerName);
    _phoneController = TextEditingController(text: currentProfile.phone);
    _addressController = TextEditingController(text: currentProfile.address);
    _upiIdController = TextEditingController(text: currentProfile.upiId);
    _gstController = TextEditingController(text: currentProfile.gstNumber);
    _logoBase64 = currentProfile.logoBase64;
    _selectedThemeColor = currentProfile.themeColorValue;
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _upiIdController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        setState(() {
          _logoBase64 = base64String;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logo upload me error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Dukaan Ka Logo Upload Karein',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                ),
                title: Text('Gallery se chunein', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                ),
                title: Text('Camera se photo kheenche', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_logoBase64.isNotEmpty) ...[
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.dangerLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                  ),
                  title: Text('Logo Hatayein (Remove)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.danger)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _logoBase64 = '');
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final newProfile = ShopProfile(
      shopName: _shopNameController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      upiId: _upiIdController.text.trim(),
      gstNumber: _gstController.text.trim(),
      logoBase64: _logoBase64,
      themeColorValue: _selectedThemeColor,
    );

    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    await shopProvider.saveProfile(newProfile);

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (widget.isEditMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dukaan Details Safaltapoorvak Update Ho Gayi!'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BillingHomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = Color(_selectedThemeColor);
    final shopProvider = Provider.of<ShopProvider>(context);
    final isDark = shopProvider.isDarkMode;
    final surfaceColor = Theme.of(context).cardColor;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: widget.isEditMode
          ? AppBar(
              title: const Text('Dukaan Details & Settings'),
              backgroundColor: surfaceColor,
              elevation: 0,
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.isEditMode) ...[
                  const SizedBox(height: 8),
                  // Welcome Header Banner with Dynamic Theme
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [currentColor, currentColor.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: currentColor.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.storefront_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dukaan Setup Karein',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Dukaan details aur theme customize karein',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ================= LOGO UPLOAD SECTION =================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      // Logo Avatar Preview
                      GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: currentColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: currentColor.withValues(alpha: 0.4), width: 1.5),
                          ),
                          child: _logoBase64.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.memory(
                                    base64Decode(_logoBase64),
                                    fit: BoxFit.cover,
                                    width: 68,
                                    height: 68,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined, color: currentColor, size: 24),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Logo',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: currentColor,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Logo Upload Text & Button
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dukaan Ka Logo (Optional)',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            Text(
                              'Bill invoice par logo print hoga',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: _showImageSourceDialog,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: currentColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _logoBase64.isNotEmpty ? Icons.edit_rounded : Icons.upload_file_rounded,
                                      size: 14,
                                      color: currentColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _logoBase64.isNotEmpty ? 'Logo Badlein' : 'Upload Logo',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: currentColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ================= THEME COLOR SELECTION =================
                Text(
                  'App & Bill Theme Color',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Apni dukaan ka manpasand color chunein',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 10),

                // Color Swatches Grid
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppConstants.themeColorOptions.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final item = AppConstants.themeColorOptions[index];
                      final color = item['color'] as Color;
                      final isSelected = color.toARGB32() == _selectedThemeColor;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedThemeColor = color.toARGB32();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                            ],
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                              : null,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // ================= DARK MODE TOGGLE TILE =================
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.amber.withValues(alpha: 0.15) : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: isDark ? Colors.amber : AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dark Mode (डार्क मोड)',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            Text(
                              isDark ? 'Dark theme active hai' : 'Raat me aasan billing ke liye',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isDark,
                        activeThumbColor: currentColor,
                        onChanged: (val) {
                          shopProvider.setDarkMode(val);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ================= MANDATORY DETAILS =================
                Text(
                  'Zaroori Jankari (Mandatory)',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Input 1: Dukaan Ka Naam
                CustomTextField(
                  label: 'Dukaan Ka Naam *',
                  hint: 'e.g., Shree Ganesh Kirana Store',
                  controller: _shopNameController,
                  prefixIcon: Icons.store_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Kripya Dukaan Ka Naam Dalein';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Input 2: Malik Ka Naam
                CustomTextField(
                  label: 'Malik Ka Naam (Owner Name) *',
                  hint: 'e.g., Ramesh Kumar Maurya',
                  controller: _ownerNameController,
                  prefixIcon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Kripya Malik Ka Naam Dalein';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Input 3: Mobile Number
                CustomTextField(
                  label: 'Mobile Number *',
                  hint: '9876543210',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixWidget: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone_outlined, color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '+91',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 20,
                          color: AppColors.border,
                        ),
                      ],
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Kripya Mobile Number Dalein';
                    }
                    if (value.trim().length < 10) {
                      return 'Kripya Sahi 10-Digit Mobile Number Dalein';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // ================= OPTIONAL DETAILS =================
                Row(
                  children: [
                    Text(
                      'Anya Jankari (Optional)',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: currentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Invoice pe aayega',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: currentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Input 4: Shop Address (Replacing 'Pata' with 'Shop Address')
                CustomTextField(
                  label: 'Shop Address (दुकान का पता)',
                  hint: 'e.g., Shop No. 12, Main Market, Varanasi',
                  controller: _addressController,
                  prefixIcon: Icons.location_on_outlined,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 14),

                // Input 5: UPI ID
                CustomTextField(
                  label: 'UPI ID (QR Code Payment ke liye)',
                  hint: 'e.g., 9876543210@paytm ya gpay',
                  subLabel: 'Bill pe QR aayega',
                  controller: _upiIdController,
                  prefixIcon: Icons.qr_code_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),

                // Input 6: GST Number
                CustomTextField(
                  label: 'GST Number (Agar hai toh)',
                  hint: 'e.g., 07AAAAA0000A1Z5',
                  controller: _gstController,
                  prefixIcon: Icons.receipt_outlined,
                  textCapitalization: TextCapitalization.characters,
                ),

                const SizedBox(height: 32),

                // Save Button
                CustomButton(
                  text: widget.isEditMode ? 'Details & Theme Save Karein' : 'Save & Start (दुकान शुरू करें)',
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: _isSaving,
                  onPressed: _handleSave,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
