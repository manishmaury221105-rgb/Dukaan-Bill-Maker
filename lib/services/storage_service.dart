import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shop_profile.dart';
import '../models/bill_model.dart';
import '../utils/constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Check if user has completed first time onboarding
  static Future<bool> isOnboarded() async {
    final prefs = await _instance;
    return prefs.getBool(AppConstants.keyIsOnboarded) ?? false;
  }

  /// Get Dark Mode preference
  static Future<bool> isDarkMode() async {
    final prefs = await _instance;
    return prefs.getBool(AppConstants.keyIsDarkMode) ?? false;
  }

  /// Save Dark Mode preference
  static Future<void> setDarkMode(bool isDark) async {
    final prefs = await _instance;
    await prefs.setBool(AppConstants.keyIsDarkMode, isDark);
  }

  /// Save shop profile
  static Future<void> saveShopProfile(ShopProfile profile) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.keyShopName, profile.shopName);
    await prefs.setString(AppConstants.keyOwnerName, profile.ownerName);
    await prefs.setString(AppConstants.keyPhone, profile.phone);
    await prefs.setString(AppConstants.keyAddress, profile.address);
    await prefs.setString(AppConstants.keyUpiId, profile.upiId);
    await prefs.setString(AppConstants.keyGstNumber, profile.gstNumber);
    await prefs.setString(AppConstants.keyLogoBase64, profile.logoBase64);
    await prefs.setInt(AppConstants.keyThemeColor, profile.themeColorValue);
    await prefs.setBool(AppConstants.keyIsOnboarded, true);
  }

  /// Load shop profile
  static Future<ShopProfile> loadShopProfile() async {
    final prefs = await _instance;
    return ShopProfile(
      shopName: prefs.getString(AppConstants.keyShopName) ?? '',
      ownerName: prefs.getString(AppConstants.keyOwnerName) ?? '',
      phone: prefs.getString(AppConstants.keyPhone) ?? '',
      address: prefs.getString(AppConstants.keyAddress) ?? '',
      upiId: prefs.getString(AppConstants.keyUpiId) ?? '',
      gstNumber: prefs.getString(AppConstants.keyGstNumber) ?? '',
      logoBase64: prefs.getString(AppConstants.keyLogoBase64) ?? '',
      themeColorValue: prefs.getInt(AppConstants.keyThemeColor) ?? 0xFF00A859,
    );
  }

  /// Generate next 4-digit Bill Number
  static Future<String> generateBillNumber() async {
    final prefs = await _instance;
    int lastSeq = prefs.getInt(AppConstants.keyLastBillSequence) ?? 1000;
    lastSeq++;
    if (lastSeq > 9999) {
      lastSeq = 1001;
    }
    await prefs.setInt(AppConstants.keyLastBillSequence, lastSeq);
    return lastSeq.toString();
  }

  /// Alternatively generate a random 4-digit bill number
  static String generateRandomBillNumber() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  /// Save bill to local history
  static Future<void> saveBillToHistory(BillModel bill) async {
    final prefs = await _instance;
    final List<String> existingBillsJson = prefs.getStringList(AppConstants.keyBillHistory) ?? [];
    
    // Check if bill already exists in list (update it), otherwise insert at top
    final existingIndex = existingBillsJson.indexWhere((jsonStr) {
      try {
        final map = json.decode(jsonStr) as Map<String, dynamic>;
        return map['id'] == bill.id || map['billNumber'] == bill.billNumber;
      } catch (_) {
        return false;
      }
    });

    if (existingIndex >= 0) {
      existingBillsJson[existingIndex] = bill.toJson();
    } else {
      existingBillsJson.insert(0, bill.toJson());
    }

    await prefs.setStringList(AppConstants.keyBillHistory, existingBillsJson);
  }

  /// Load all saved bills
  static Future<List<BillModel>> loadBillHistory() async {
    final prefs = await _instance;
    final List<String> list = prefs.getStringList(AppConstants.keyBillHistory) ?? [];
    final List<BillModel> result = [];
    for (final jsonStr in list) {
      try {
        result.add(BillModel.fromJson(jsonStr));
      } catch (e) {
        // Skip corrupt entry
      }
    }
    return result;
  }

  /// Delete a bill from history
  static Future<void> deleteBillFromHistory(String billId) async {
    final prefs = await _instance;
    final List<String> list = prefs.getStringList(AppConstants.keyBillHistory) ?? [];
    list.removeWhere((jsonStr) {
      try {
        final map = json.decode(jsonStr) as Map<String, dynamic>;
        return map['id'] == billId;
      } catch (_) {
        return false;
      }
    });
    await prefs.setStringList(AppConstants.keyBillHistory, list);
  }

  /// Clear all history
  static Future<void> clearHistory() async {
    final prefs = await _instance;
    await prefs.remove(AppConstants.keyBillHistory);
  }
}
