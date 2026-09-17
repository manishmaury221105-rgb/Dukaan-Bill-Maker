import 'package:flutter_test/flutter_test.dart';
import 'package:dukaan_bill_maker/models/bill_item.dart';
import 'package:dukaan_bill_maker/models/bill_model.dart';
import 'package:dukaan_bill_maker/models/shop_profile.dart';
import 'package:dukaan_bill_maker/utils/formatters.dart';
import 'package:dukaan_bill_maker/providers/billing_provider.dart';
import 'package:dukaan_bill_maker/services/pdf_service.dart';

void main() {
  group('BillItem Model Tests', () {
    test('Calculates total correctly for whole numbers', () {
      final item = BillItem(name: 'Chawal', price: 50.0, quantity: 3.0, unit: 'Kg');
      expect(item.total, 150.0);
    });

    test('Calculates total correctly for decimal quantity', () {
      final item = BillItem(name: 'Sarson Tel', price: 160.0, quantity: 0.5, unit: 'Liter');
      expect(item.total, 80.0);
    });
  });

  group('BillModel Calculation Tests', () {
    test('Calculates subtotal and grand total with flat discount', () {
      final items = [
        BillItem(name: 'Aata', price: 40.0, quantity: 5.0, unit: 'Kg'), // 200
        BillItem(name: 'Cheeni', price: 45.0, quantity: 2.0, unit: 'Kg'), // 90
      ];

      final bill = BillModel(
        billNumber: '1001',
        items: items,
        discount: 20.0,
        discountType: 'flat',
      );

      expect(bill.subtotal, 290.0);
      expect(bill.discountAmount, 20.0);
      expect(bill.grandTotal, 270.0);
    });

    test('Calculates subtotal and grand total with percentage discount', () {
      final items = [
        BillItem(name: 'Ghee', price: 500.0, quantity: 1.0, unit: 'Kg'), // 500
      ];

      final bill = BillModel(
        billNumber: '1002',
        items: items,
        discount: 10.0, // 10%
        discountType: 'percent',
      );

      expect(bill.subtotal, 500.0);
      expect(bill.discountAmount, 50.0);
      expect(bill.grandTotal, 450.0);
    });
  });

  group('Formatters Tests', () {
    test('Currency formatting with Rupee symbol', () {
      expect(Formatters.formatCurrency(150.0), '₹150');
      expect(Formatters.formatCurrency(150.50, showDecimals: true), '₹150.50');
    });

    test('Number formatting without trailing zeroes', () {
      expect(Formatters.formatNumber(2.0), '2');
      expect(Formatters.formatNumber(2.5), '2.5');
      expect(Formatters.formatNumber(2.75), '2.75');
    });
  });

  group('ShopProfile Model Tests', () {
    test('Validation returns true when shopName, ownerName and phone are present', () {
      const validProfile = ShopProfile(
        shopName: 'Shree Ganesh Store',
        ownerName: 'Ramesh Maurya',
        phone: '9876543210',
      );
      expect(validProfile.isValid, true);

      const invalidProfile = ShopProfile(
        shopName: '',
        ownerName: 'Ramesh',
        phone: '9876543210',
      );
      expect(invalidProfile.isValid, false);
    });
  });

  group('BillingProvider Tests', () {
    test('Adding and updating items updates totals', () {
      final provider = BillingProvider();
      expect(provider.items.length, 1);

      provider.updateItemName(0, 'Doodh');
      provider.updateItemPrice(0, 30.0);
      provider.updateItemQuantity(0, 2.0);

      expect(provider.subtotal, 60.0);
      expect(provider.grandTotal, 60.0);

      provider.addItem();
      expect(provider.items.length, 2);

      provider.updateItemName(1, 'Dahi');
      provider.updateItemPrice(1, 40.0);
      provider.updateItemQuantity(1, 1.0);

      expect(provider.subtotal, 100.0);

      provider.setDiscount(10.0);
      expect(provider.discountAmount, 10.0);
      expect(provider.grandTotal, 90.0);
    });
  });

  group('PdfService Tests', () {
    test('generateInvoice produces valid non-empty PDF bytes', () async {
      const shop = ShopProfile(
        shopName: 'Mani Store',
        ownerName: 'Manish',
        phone: '9876543210',
        address: 'Main Market, Delhi',
      );
      final items = [
        BillItem(name: 'Chawal', price: 50.0, quantity: 2.0, unit: 'Kg'),
      ];
      final bill = BillModel(
        billNumber: '2474',
        items: items,
      );

      final bytes = await PdfService.generateInvoice(shop: shop, bill: bill);
      expect(bytes.isNotEmpty, true);
      expect(bytes.length, greaterThan(1000)); // PDF files are typically > 1KB
      // Check PDF header signature '%PDF'
      final header = String.fromCharCodes(bytes.take(4));
      expect(header, '%PDF');
    });
  });
}
