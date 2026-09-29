import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 0)
class Item {
  @HiveField(0)
  String id;          // Unique ID
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  int quantity;
  
  @HiveField(3)
  String category;
  
  @HiveField(4)
  String addedBy;
  
  @HiveField(5)
  bool isDone;
  
  @HiveField(6)
  String? assignedTo; // Optional user ID
  
  @HiveField(7)
  String? barcode;    // Optional barcode

  Item({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
    required this.addedBy,
    this.isDone = false,
    this.assignedTo,
    this.barcode,
  });

  // ------------------ JSON Serialization ------------------
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'] ?? 1,
      category: json['category'] ?? 'Misc',
      addedBy: json['added_by'] ?? 'Guest',
      isDone: json['is_done'] ?? false,
      assignedTo: json['assigned_to'],
      barcode: json['barcode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category,
      'added_by': addedBy,
      'is_done': isDone,
      'assigned_to': assignedTo,
      'barcode': barcode,
    };
  }
}
