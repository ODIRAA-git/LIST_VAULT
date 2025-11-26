import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/item.dart';
import '../models/user.dart' as models;
import '../utils/categories.dart';
import '../services/voice_input_service.dart';
import '../services/notification_service.dart';

class AddItemScreen extends StatefulWidget {
  final models.User? currentUser;

  const AddItemScreen({super.key, this.currentUser});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: "1");
  final _voiceService = VoiceInputService();

  String selectedCategory = AppCategories.all.first.name;
  bool isListening = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _voiceService.initialize();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  Future<void> _startVoiceInput() async {
    setState(() => isListening = true);
    final text = await _voiceService.startListening();
    setState(() => isListening = false);

    if (text != null && text.isNotEmpty) {
      _nameController.text = text;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Heard: "$text"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _saveItemToSupabase() async {
    final name = _nameController.text.trim();
    final quantity = int.tryParse(_quantityController.text) ?? 1;

    final userId = widget.currentUser?.id ?? 'guest';
    final userName = widget.currentUser?.name ?? 'Guest';
    final familyId = widget.currentUser?.familyGroupId ?? '';

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Item name cannot be empty."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    final item = Item(
      id: Uuid().v4(),
      name: name,
      quantity: quantity,
      category: selectedCategory,
      addedBy: userName,
    );

    // 🔥🔥🔥 DEBUG PRINTS TO CHECK REAL DEVICE VALUES
    print("=========== DEBUG ADD ITEM ===========");
    print("ITEM ID: ${item.id}");
    print("USER ID: $userId");
    print("USER NAME: $userName");
    print("FAMILY GROUP ID: $familyId");
    print("======================================");

    try {
      await Supabase.instance.client.from('items').insert([
        {
          'id': item.id,
          'name': item.name,
          'quantity': item.quantity,
          'category': item.category,
          'added_by': userName,
          'is_done': item.isDone,
          'family_group_id': familyId,
          'created_at': DateTime.now().toIso8601String(),
        }
      ]);

      // Try to show notification, but don't let it fail the whole operation
      if (widget.currentUser != null) {
        try {
          await NotificationService().showItemAddedNotification(
            userName: userName,
            itemName: name,
          );
        } catch (notificationError) {
          // Silently ignore notification errors - item was added successfully
          print('Notification failed (non-critical): $notificationError');
        }
      }

      if (!mounted) return;
      Navigator.pop(context, item);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Item"),
        actions: [
          IconButton(
            icon: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              color: isListening ? Colors.red : null,
            ),
            onPressed: isListening ? null : _startVoiceInput,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Item Name",
                prefixIcon: const Icon(Icons.shopping_cart),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: "Quantity",
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Category",
                prefixIcon: Icon(
                  AppCategories.getIcon(selectedCategory),
                  color: AppCategories.getColor(selectedCategory),
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              value: selectedCategory,
              items: AppCategories.all.map((category) {
                return DropdownMenuItem(
                  value: category.name,
                  child: Row(
                    children: [
                      Icon(category.icon, color: category.color),
                      const SizedBox(width: 10),
                      Text(category.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => selectedCategory = value!),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Add Item", style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isSaving ? null : _saveItemToSupabase,
            ),
          ],
        ),
      ),
    );
  }
}
