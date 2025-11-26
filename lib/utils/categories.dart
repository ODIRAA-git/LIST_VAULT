import 'package:flutter/material.dart';

class ItemCategory {
  final String name;
  final IconData icon;
  final Color color;

  const ItemCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class AppCategories {
  static const List<ItemCategory> all = [
    ItemCategory(
      name: 'Fruits',
      icon: Icons.apple,
      color: Colors.red,
    ),
    ItemCategory(
      name: 'Vegetables',
      icon: Icons.eco,
      color: Colors.green,
    ),
    ItemCategory(
      name: 'Dairy',
      icon: Icons.local_drink,
      color: Colors.blue,
    ),
    ItemCategory(
      name: 'Bakery',
      icon: Icons.bakery_dining,
      color: Colors.brown,
    ),
    ItemCategory(
      name: 'Meat',
      icon: Icons.set_meal,
      color: Colors.deepOrange,
    ),
    ItemCategory(
      name: 'Seafood',
      icon: Icons.set_meal_outlined,
      color: Colors.cyan,
    ),
    ItemCategory(
      name: 'Snacks',
      icon: Icons.cookie,
      color: Colors.purple,
    ),
    ItemCategory(
      name: 'Beverages',
      icon: Icons.local_cafe,
      color: Colors.amber,
    ),
    ItemCategory(
      name: 'Frozen',
      icon: Icons.ac_unit,
      color: Colors.lightBlue,
    ),
    ItemCategory(
      name: 'Canned',
      icon: Icons.inventory_2,
      color: Colors.grey,
    ),
    ItemCategory(
      name: 'Cleaning',
      icon: Icons.cleaning_services,
      color: Colors.teal,
    ),
    ItemCategory(
      name: 'Personal Care',
      icon: Icons.face,
      color: Colors.pink,
    ),
    ItemCategory(
      name: 'Baby',
      icon: Icons.child_care,
      color: Colors.lightGreen,
    ),
    ItemCategory(
      name: 'Pet',
      icon: Icons.pets,
      color: Colors.orange,
    ),
    ItemCategory(
      name: 'Other',
      icon: Icons.shopping_basket,
      color: Colors.blueGrey,
    ),
  ];

  static List<String> get names => all.map((c) => c.name).toList();

  static ItemCategory getByName(String name) {
    return all.firstWhere(
      (category) => category.name == name,
      orElse: () => all.last, // Returns 'Other' if not found
    );
  }

  static Color getColor(String name) {
    return getByName(name).color;
  }

  static IconData getIcon(String name) {
    return getByName(name).icon;
  }
}
