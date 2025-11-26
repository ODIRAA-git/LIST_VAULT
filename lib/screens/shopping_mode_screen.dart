import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item.dart';
import '../models/user.dart' as models;
import '../utils/categories.dart';

class ShoppingModeScreen extends StatefulWidget {
  final models.User currentUser;

  const ShoppingModeScreen({super.key, required this.currentUser});

  @override
  State<ShoppingModeScreen> createState() => _ShoppingModeScreenState();
}

class _ShoppingModeScreenState extends State<ShoppingModeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Item> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchItems();
    _setupRealtimeListener();
  }

  Future<void> _fetchItems() async {
    setState(() => isLoading = true);
    try {
      final data = await supabase
          .from('items')
          .select()
          .eq('family_group_id', widget.currentUser.familyGroupId ?? '')
          .order('created_at', ascending: true);

      setState(() {
        items = (data as List)
            .map((e) => Item(
                  id: e['id'],
                  name: e['name'],
                  quantity: e['quantity'],
                  category: e['category'],
                  addedBy: e['added_by'],
                  isDone: e['is_done'] ?? false,
                ))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading items: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _setupRealtimeListener() {
    supabase
        .channel('shopping_items_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'items',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'family_group_id',
            value: widget.currentUser.familyGroupId,
          ),
          callback: (payload) {
            final data = payload.newRecord;
            if (data != null) {
              setState(() {
                items.add(Item(
                  id: data['id'],
                  name: data['name'],
                  quantity: data['quantity'],
                  category: data['category'],
                  addedBy: data['added_by'],
                  isDone: data['is_done'] ?? false,
                ));
              });
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'items',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'family_group_id',
            value: widget.currentUser.familyGroupId,
          ),
          callback: (payload) {
            final data = payload.newRecord;
            if (data != null) {
              final index = items.indexWhere((i) => i.id == data['id']);
              if (index != -1) {
                setState(() {
                  items[index] = Item(
                    id: data['id'],
                    name: data['name'],
                    quantity: data['quantity'],
                    category: data['category'],
                    addedBy: data['added_by'],
                    isDone: data['is_done'] ?? false,
                  );
                });
              }
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'items',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'family_group_id',
            value: widget.currentUser.familyGroupId,
          ),
          callback: (payload) {
            final deletedId = payload.oldRecord?['id'];
            if (deletedId != null) {
              setState(() {
                items.removeWhere((i) => i.id == deletedId);
              });
            }
          },
        )
        .subscribe();
  }

  Future<void> toggleItemDone(Item item) async {
    final updated = !item.isDone;
    try {
      await supabase
          .from('items')
          .update({'is_done': updated})
          .eq('id', item.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = items.where((item) => item.isDone).length;
    final total = items.length;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Shopping Mode', style: TextStyle(fontSize: 24)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                '$completed / $total',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 100, color: Colors.grey.shade400),
                      const SizedBox(height: 20),
                      Text(
                        'No items in your list',
                        style: TextStyle(fontSize: 24, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: item.isDone ? 1 : 4,
                      color: item.isDone ? Colors.grey.shade300 : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: item.isDone ? Colors.green : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => toggleItemDone(item),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              // Large checkbox
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: item.isDone ? Colors.green : Colors.white,
                                  border: Border.all(
                                    color: item.isDone
                                        ? Colors.green
                                        : Colors.grey.shade400,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: item.isDone
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 40)
                                    : null,
                              ),
                              const SizedBox(width: 20),

                              // Item details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        decoration: item.isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: item.isDone
                                            ? Colors.grey.shade600
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppCategories.getColor(item.category)
                                                .withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color:
                                                  AppCategories.getColor(item.category),
                                              width: 2,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                AppCategories.getIcon(item.category),
                                                size: 20,
                                                color:
                                                    AppCategories.getColor(item.category),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                item.category,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppCategories.getColor(
                                                      item.category),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade100,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'Qty: ${item.quantity}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
