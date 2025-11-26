import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'item.dart';

enum WeekStatus {
  active,
  completed,
  archived,
}

class WeeklyList {
  String? id; // Supabase UUID
  String name;
  List<Item> items;
  int weekNumber;
  int year;
  String status; // 'active', 'completed', 'archived'
  DateTime startDate;
  DateTime endDate;
  String familyGroupId;

  WeeklyList({
    this.id,
    required this.name,
    required List<Item> items,
    required this.weekNumber,
    required this.year,
    this.status = 'active',
    required this.startDate,
    required this.endDate,
    required this.familyGroupId,
  }) : items = items.map((item) {
          // Assign a fresh UUID to every item when creating a new WeeklyList
          return Item(
            id: const Uuid().v4(),
            name: item.name,
            quantity: item.quantity,
            category: item.category,
            addedBy: item.addedBy,
            isDone: item.isDone,
          );
        }).toList();

  // ------------------ HELPERS ------------------
  bool isActive() => status == 'active';
  bool isCompleted() => status == 'completed';

  double getCompletionPercentage() {
    if (items.isEmpty) return 0.0;
    int completedCount = items.where((item) => item.isDone).length;
    return (completedCount / items.length) * 100;
  }

  List<Item> getUncheckedItems() => items.where((item) => !item.isDone).toList();

  void markAsCompleted() => status = 'completed';

  // ------------------ JSON SERIALIZATION ------------------
  factory WeeklyList.fromJson(Map<String, dynamic> json) {
    return WeeklyList(
      id: json['id'],
      name: json['name'],
      weekNumber: json['week_number'],
      year: json['year'],
      status: json['status'] ?? 'active',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      familyGroupId: json['family_group_id'],
      items: (json['items'] as List<dynamic>? ?? [])
          .map((itemJson) => Item.fromJson(itemJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'week_number': weekNumber,
      'year': year,
      'status': status,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'family_group_id': familyGroupId,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}
