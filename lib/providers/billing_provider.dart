import 'package:flutter/material.dart';
import '../models/bill_item.dart';
import '../models/bill_model.dart';
import '../services/storage_service.dart';

class BillingProvider extends ChangeNotifier {
  String _billNumber = '';
  DateTime _date = DateTime.now();
  String _customerName = '';
  String _customerPhone = '';
  List<BillItem> _items = [];
  double _discount = 0.0;
  String _discountType = 'flat'; // 'flat' or 'percent'
  String _notes = '';

  BillingProvider() {
    initNewBill();
  }

  // Getters
  String get billNumber => _billNumber;
  DateTime get date => _date;
  String get customerName => _customerName;
  String get customerPhone => _customerPhone;
  List<BillItem> get items => _items;
  double get discount => _discount;
  String get discountType => _discountType;
  String get notes => _notes;

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.total);

  double get discountAmount {
    if (_discount <= 0) return 0.0;
    if (_discountType == 'percent') {
      return (subtotal * _discount) / 100.0;
    }
    return _discount > subtotal ? subtotal : _discount;
  }

  double get grandTotal {
    final total = subtotal - discountAmount;
    return total < 0 ? 0.0 : total;
  }

  int get validItemCount => _items.where((i) => i.name.trim().isNotEmpty).length;

  bool get canGenerateBill => validItemCount > 0 && grandTotal >= 0;

  /// Initialize a brand new bill with a 4-digit number and 1 empty item
  Future<void> initNewBill() async {
    _billNumber = StorageService.generateRandomBillNumber();
    _date = DateTime.now();
    _customerName = '';
    _customerPhone = '';
    _discount = 0.0;
    _discountType = 'flat';
    _notes = '';
    _items = [
      BillItem(name: '', price: 0.0, quantity: 1.0, unit: 'Piece'),
    ];
    notifyListeners();
  }

  /// Add new empty item card
  void addItem() {
    _items.add(BillItem(name: '', price: 0.0, quantity: 1.0, unit: 'Piece'));
    notifyListeners();
  }

  /// Remove item card at index
  void removeItem(int index) {
    if (_items.length > 1) {
      _items.removeAt(index);
    } else {
      // If only one item, clear it instead of removing
      _items[0] = BillItem(name: '', price: 0.0, quantity: 1.0, unit: 'Piece');
    }
    notifyListeners();
  }

  /// Update item fields
  void updateItemName(int index, String name) {
    if (index >= 0 && index < _items.length) {
      _items[index].name = name;
      notifyListeners();
    }
  }

  void updateItemPrice(int index, double price) {
    if (index >= 0 && index < _items.length) {
      _items[index].price = price;
      notifyListeners();
    }
  }

  void updateItemQuantity(int index, double quantity) {
    if (index >= 0 && index < _items.length) {
      _items[index].quantity = quantity > 0 ? quantity : 1.0;
      notifyListeners();
    }
  }

  void updateItemUnit(int index, String unit) {
    if (index >= 0 && index < _items.length) {
      _items[index].unit = unit;
      notifyListeners();
    }
  }

  void incrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index].quantity += 1.0;
      notifyListeners();
    }
  }

  void decrementQuantity(int index) {
    if (index >= 0 && index < _items.length && _items[index].quantity > 1.0) {
      _items[index].quantity -= 1.0;
      notifyListeners();
    }
  }

  /// Update Discount
  void setDiscount(double discount, {String? type}) {
    _discount = discount >= 0 ? discount : 0.0;
    if (type != null) {
      _discountType = type;
    }
    notifyListeners();
  }

  /// Update Customer Info
  void setCustomerInfo({String? name, String? phone, String? notes}) {
    if (name != null) _customerName = name;
    if (phone != null) _customerPhone = phone;
    if (notes != null) _notes = notes;
    notifyListeners();
  }

  /// Load a past bill into the active editor
  void loadBill(BillModel bill) {
    _billNumber = bill.billNumber;
    _date = bill.date;
    _customerName = bill.customerName;
    _customerPhone = bill.customerPhone;
    _discount = bill.discount;
    _discountType = bill.discountType;
    _notes = bill.notes;
    _items = bill.items.map((i) => i.copyWith()).toList();
    if (_items.isEmpty) {
      _items.add(BillItem(name: '', price: 0.0, quantity: 1.0, unit: 'Piece'));
    }
    notifyListeners();
  }

  /// Convert current state into a BillModel
  BillModel toBillModel() {
    // Filter out items without a name
    final validItems = _items.where((i) => i.name.trim().isNotEmpty).toList();
    return BillModel(
      billNumber: _billNumber,
      date: _date,
      customerName: _customerName,
      customerPhone: _customerPhone,
      items: validItems.isNotEmpty ? validItems : _items,
      discount: _discount,
      discountType: _discountType,
      notes: _notes,
    );
  }
}
