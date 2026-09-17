import 'package:uuid/uuid.dart';

class BillItem {
  final String id;
  String name;
  double price;
  double quantity;
  String unit;

  BillItem({
    String? id,
    this.name = '',
    this.price = 0.0,
    this.quantity = 1.0,
    this.unit = 'Piece',
  }) : id = id ?? const Uuid().v4();

  /// Row total auto calculated: Price * Quantity
  double get total => price * quantity;

  BillItem copyWith({
    String? id,
    String? name,
    double? price,
    double? quantity,
    String? unit,
  }) {
    return BillItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory BillItem.fromMap(Map<String, dynamic> map) {
    return BillItem(
      id: map['id'] as String? ?? const Uuid().v4(),
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: map['unit'] as String? ?? 'Piece',
    );
  }
}
