import 'package:flutter/material.dart';
import '../models/item.dart';

class CarryOverScreen extends StatefulWidget {
  final List<Item> uncheckedItems;

  const CarryOverScreen({super.key, required this.uncheckedItems});

  @override
  State<CarryOverScreen> createState() => _CarryOverScreenState();
}

class _CarryOverScreenState extends State<CarryOverScreen> {
  late Map<String, bool> selectedItems;
  bool selectAll = true;

  @override
  void initState() {
    super.initState();
    // Initialize all items as selected by default
    selectedItems = {for (var item in widget.uncheckedItems) item.id: true};
  }

  Map<String, List<Item>> _groupItemsByCategory() {
    final grouped = <String, List<Item>>{};
    for (var item in widget.uncheckedItems) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }

  List<Item> _getSelectedItems() {
    return widget.uncheckedItems
        .where((item) => selectedItems[item.id] == true)
        .toList();
  }

  void _toggleSelectAll() {
    setState(() {
      selectAll = !selectAll;
      for (var key in selectedItems.keys) {
        selectedItems[key] = selectAll;
      }
    });
  }

  void _toggleCategory(String category, bool value) {
    setState(() {
      for (var item in widget.uncheckedItems
          .where((i) => i.category == category)) {
        selectedItems[item.id] = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupItemsByCategory();
    final selectedCount = _getSelectedItems().length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review & Carry Over"),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient:
                  LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade600]),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select items to carry over",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "$selectedCount of ${widget.uncheckedItems.length} items selected",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _toggleSelectAll,
                  icon: Icon(selectAll ? Icons.deselect : Icons.select_all,
                      color: Colors.white),
                  label: Text(selectAll ? "Deselect All" : "Select All",
                      style: const TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),

          // Items list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedItems.length,
              itemBuilder: (context, index) {
                final category = groupedItems.keys.elementAt(index);
                final items = groupedItems[category]!;
                final selectedInCategory =
                    items.where((i) => selectedItems[i.id] == true).length;
                return _buildCategorySection(category, items, selectedInCategory);
              },
            ),
          ),

          // Bottom bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, <Item>[]),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade400, width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Skip",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: selectedCount > 0
                        ? () => Navigator.pop(context, _getSelectedItems())
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text("Carry Over ($selectedCount)",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category, List<Item> items, int selectedCount) {
    final allSelected = selectedCount == items.length;
    final someSelected = selectedCount > 0 && selectedCount < items.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Category header
          InkWell(
            onTap: () => _toggleCategory(category, !allSelected),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getCategoryColor(category).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: allSelected ? true : (someSelected ? null : false),
                    tristate: true,
                    onChanged: (val) => _toggleCategory(category, val ?? false),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "$category ($selectedCount/${items.length})",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getCategoryColor(category)),
                    ),
                  ),
                  if (someSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Partial",
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Items
          ...items.map(_buildItemTile),
        ],
      ),
    );
  }

  Widget _buildItemTile(Item item) {
    final isSelected = selectedItems[item.id] ?? false;

    return CheckboxListTile(
      value: isSelected,
      onChanged: (val) {
        setState(() {
          selectedItems[item.id] = val ?? false;
        });
      },
      title: Text(item.name,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.black87 : Colors.grey.shade600)),
      subtitle: Text("Qty: ${item.quantity} • By ${item.addedBy}",
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: Colors.blue.shade600,
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Fruits':
        return Colors.red;
      case 'Vegetables':
        return Colors.green;
      case 'Dairy':
        return Colors.blue;
      case 'Bakery':
        return Colors.brown;
      case 'Meat':
        return Colors.deepOrange;
      case 'Snacks':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
