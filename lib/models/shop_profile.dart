class ShopProfile {
  final String shopName;
  final String ownerName;
  final String phone;
  final String address;
  final String upiId;
  final String gstNumber;
  final String logoBase64;
  final int themeColorValue; // e.g. 0xFF00A859

  const ShopProfile({
    this.shopName = '',
    this.ownerName = '',
    this.phone = '',
    this.address = '',
    this.upiId = '',
    this.gstNumber = '',
    this.logoBase64 = '',
    this.themeColorValue = 0xFF00A859, // Default Dukaan Green
  });

  bool get isValid => shopName.trim().isNotEmpty && ownerName.trim().isNotEmpty && phone.trim().isNotEmpty;

  ShopProfile copyWith({
    String? shopName,
    String? ownerName,
    String? phone,
    String? address,
    String? upiId,
    String? gstNumber,
    String? logoBase64,
    int? themeColorValue,
  }) {
    return ShopProfile(
      shopName: shopName ?? this.shopName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      upiId: upiId ?? this.upiId,
      gstNumber: gstNumber ?? this.gstNumber,
      logoBase64: logoBase64 ?? this.logoBase64,
      themeColorValue: themeColorValue ?? this.themeColorValue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopName': shopName,
      'ownerName': ownerName,
      'phone': phone,
      'address': address,
      'upiId': upiId,
      'gstNumber': gstNumber,
      'logoBase64': logoBase64,
      'themeColorValue': themeColorValue,
    };
  }

  factory ShopProfile.fromMap(Map<String, dynamic> map) {
    int parsedThemeColor = 0xFF00A859;
    final rawTheme = map['themeColorValue'];
    if (rawTheme is int) {
      parsedThemeColor = rawTheme;
    } else if (rawTheme is num) {
      parsedThemeColor = rawTheme.toInt();
    } else if (rawTheme is String) {
      parsedThemeColor = int.tryParse(rawTheme) ?? 0xFF00A859;
    }

    return ShopProfile(
      shopName: (map['shopName'] ?? '').toString(),
      ownerName: (map['ownerName'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
      upiId: (map['upiId'] ?? '').toString(),
      gstNumber: (map['gstNumber'] ?? '').toString(),
      logoBase64: (map['logoBase64'] ?? '').toString(),
      themeColorValue: parsedThemeColor,
    );
  }
}
