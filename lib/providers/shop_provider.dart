import 'package:flutter/material.dart';
import '../models/shop_profile.dart';
import '../services/storage_service.dart';

class ShopProvider extends ChangeNotifier {
  ShopProfile _profile = const ShopProfile();
  bool _isLoading = true;
  bool _isOnboarded = false;
  bool _isDarkMode = false;

  ShopProfile get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isOnboarded => _isOnboarded;
  bool get isDarkMode => _isDarkMode;
  String get shopName => _profile.shopName;
  String get ownerName => _profile.ownerName;
  String get phone => _profile.phone;
  String get address => _profile.address;
  String get logoBase64 => _profile.logoBase64;
  Color get primaryColor => Color(_profile.themeColorValue == 0 ? 0xFF00A859 : _profile.themeColorValue);
  int get themeColorValue => _profile.themeColorValue;

  ShopProvider() {
    loadShopData();
  }

  Future<void> loadShopData() async {
    _isLoading = true;
    notifyListeners();

    _isOnboarded = await StorageService.isOnboarded();
    _isDarkMode = await StorageService.isDarkMode();
    _profile = await StorageService.loadShopProfile();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await StorageService.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await StorageService.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> saveProfile(ShopProfile newProfile) async {
    _profile = newProfile;
    _isOnboarded = true;
    await StorageService.saveShopProfile(newProfile);
    notifyListeners();
  }

  Future<void> updateThemeColor(Color color) async {
    _profile = _profile.copyWith(themeColorValue: color.toARGB32());
    await StorageService.saveShopProfile(_profile);
    notifyListeners();
  }

  Future<void> updateLogo(String base64Image) async {
    _profile = _profile.copyWith(logoBase64: base64Image);
    await StorageService.saveShopProfile(_profile);
    notifyListeners();
  }

  Future<void> removeLogo() async {
    _profile = _profile.copyWith(logoBase64: '');
    await StorageService.saveShopProfile(_profile);
    notifyListeners();
  }
}
