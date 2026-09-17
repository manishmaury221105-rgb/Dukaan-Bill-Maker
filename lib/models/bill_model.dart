import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'bill_item.dart';

class BillModel {
  final String id;
  final String billNumber;
  final DateTime date;
  final String customerName;
  final String customerPhone;
  final List<BillItem> items;
  final double discount;
  final String discountType; // 'flat' or 'percent'
  final String notes;

  BillModel({
    String? id,
    required this.billNumber,
    DateTime? date,
    this.customerName = '',
    this.customerPhone = '',
    required this.items,
    this.discount = 0.0,
    this.discountType = 'flat',
    this.notes = '',
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  double get discountAmount {
    if (discount <= 0) return 0.0;
    if (discountType == 'percent') {
      return (subtotal * discount) / 100.0;
    }
    return discount > subtotal ? subtotal : discount;
  }

  double get grandTotal {
    final total = subtotal - discountAmount;
    return total < 0 ? 0.0 : total;
  }

  int get totalItemCount {
    return items.where((i) => i.name.trim().isNotEmpty).length;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'billNumber': billNumber,
      'date': date.toIso8601String(),
      'customerName': customerName,
      'customerPhone': customerPhone,
      'items': items.map((i) => i.toMap()).toList(),
      'discount': discount,
      'discountType': discountType,
      'notes': notes,
    };
  }

  String toJson() => json.encode(toMap());

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'] as String?,
      billNumber: map['billNumber'] as String? ?? '1001',
      date: map['date'] != null ? DateTime.parse(map['date'] as String) : DateTime.now(),
      customerName: map['customerName'] as String? ?? '',
      customerPhone: map['customerPhone'] as String? ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => BillItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      discountType: map['discountType'] as String? ?? 'flat',
      notes: map['notes'] as String? ?? '',
    );
  }

  factory BillModel.fromJson(String source) => BillModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
