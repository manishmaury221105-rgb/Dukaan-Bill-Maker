import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = "Dukaan Bill Maker";
  static const String appTagline = "Aasan, Tez aur Vishwasniya Billing";
  static const String currencySymbol = "₹";
  
  // Units for Kirana / Retail shops
  static const List<String> unitOptions = [
    'Piece',
    'Kg',
    'Gm',
    'Liter',
    'Packet',
    'Meter',
    'Box',
    'Dozen',
  ];

  // Theme Color Presets for Shopkeepers
  static const List<Map<String, dynamic>> themeColorOptions = [
    {'name': 'Dukaan Green', 'color': Color(0xFF00A859)},
    {'name': 'Royal Blue', 'color': Color(0xFF2563EB)},
    {'name': 'Midnight Navy', 'color': Color(0xFF0F172A)},
    {'name': 'Crimson Red', 'color': Color(0xFFDC2626)},
    {'name': 'Saffron Orange', 'color': Color(0xFFEA580C)},
    {'name': 'Deep Purple', 'color': Color(0xFF7C3AED)},
    {'name': 'Teal', 'color': Color(0xFF0D9488)},
    {'name': 'Emerald', 'color': Color(0xFF059669)},
  ];

  // Common Indian Kirana & Retail item suggestions
  static const List<String> commonSamanSuggestions = [
    'Aata (आटा)',
    'Chawal (चावल)',
    'Toor Daal (तूर दाल)',
    'Moong Daal (मूंग दाल)',
    'Cheeni (चीनी)',
    'Sarson Tel (सरसों तेल)',
    'Refined Tel (रिफाइंड तेल)',
    'Chai Patti (चाय पत्ती)',
    'Namak (नमक)',
    'Haldi Powder (हल्दी पाउडर)',
    'Mirchi Powder (मिर्ची पाउडर)',
    'Dhaniya Powder (धनिया पाउडर)',
    'Garam Masala (गरम मसाला)',
    'Doodh (दूध)',
    'Dahi (दही)',
    'Paneer (पनीर)',
    'Ghee (घी)',
    'Biskut (बिस्कुट)',
    'Sabun (साबुन)',
    'Surf / Detergent (सर्फ)',
    'Shampoo (शैम्पू)',
    'Toothpaste (पेस्ट)',
  ];

  // Shared preferences keys
  static const String keyShopName = 'shop_name';
  static const String keyOwnerName = 'owner_name';
  static const String keyPhone = 'phone_number';
  static const String keyAddress = 'shop_address';
  static const String keyUpiId = 'shop_upi_id';
  static const String keyGstNumber = 'shop_gst_number';
  static const String keyLogoBase64 = 'shop_logo_base64';
  static const String keyThemeColor = 'shop_theme_color';
  static const String keyIsOnboarded = 'is_onboarded';
  static const String keyIsDarkMode = 'is_dark_mode';
  static const String keyBillHistory = 'bill_history_v1';
  static const String keyLastBillSequence = 'last_bill_sequence';
}
