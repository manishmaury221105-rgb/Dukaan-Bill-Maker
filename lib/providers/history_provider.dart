import 'package:flutter/material.dart';
import '../models/bill_model.dart';
import '../services/storage_service.dart';

class HistoryProvider extends ChangeNotifier {
  List<BillModel> _bills = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<BillModel> get bills {
    if (_searchQuery.trim().isEmpty) {
      return _bills;
    }
    final query = _searchQuery.toLowerCase().trim();
    return _bills.where((bill) {
      final matchesBillNo = bill.billNumber.toLowerCase().contains(query);
      final matchesCustomer = bill.customerName.toLowerCase().contains(query);
      final matchesPhone = bill.customerPhone.contains(query);
      final matchesItems = bill.items.any((i) => i.name.toLowerCase().contains(query));
      return matchesBillNo || matchesCustomer || matchesPhone || matchesItems;
    }).toList();
  }

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // Statistics
  double get todaySales {
    final now = DateTime.now();
    return _bills.where((b) {
      return b.date.year == now.year &&
          b.date.month == now.month &&
          b.date.day == now.day;
    }).fold(0.0, (sum, b) => sum + b.grandTotal);
  }

  int get todayBillsCount {
    final now = DateTime.now();
    return _bills.where((b) {
      return b.date.year == now.year &&
          b.date.month == now.month &&
          b.date.day == now.day;
    }).length;
  }

  double get totalLifetimeSales {
    return _bills.fold(0.0, (sum, b) => sum + b.grandTotal);
  }

  int get totalBillsCount => _bills.length;

  HistoryProvider() {
    loadHistory();
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    _bills = await StorageService.loadBillHistory();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveBill(BillModel bill) async {
    await StorageService.saveBillToHistory(bill);
    await loadHistory();
  }

  Future<void> deleteBill(String billId) async {
    await StorageService.deleteBillFromHistory(billId);
    _bills.removeWhere((b) => b.id == billId);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> clearAll() async {
    await StorageService.clearHistory();
    _bills.clear();
    notifyListeners();
  }
}
