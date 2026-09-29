import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/item.dart';
import '../models/user.dart' as models;
import '../providers/theme_provider.dart';
import '../services/family_service.dart';
import '../widgets/family_code_dialog.dart';

import 'add_item_screen.dart';
import 'shopping_mode_screen.dart';
import 'carry_over_screen.dart';

class HomeScreen extends StatefulWidget {
  final models.User currentUser;

  const HomeScreen({super.key, required this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Item> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchItems();
    _setupRealtimeListener();
    _checkAndCarryOverWeek(); // <-- New automatic weekly rollover
  }

  // ------------------- FETCH ITEMS -------------------
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
    }
  }

  // ------------------- REALTIME -------------------
  void _setupRealtimeListener() {
    supabase
        .channel('items_channel')
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

  // ------------------- WEEKLY MANAGEMENT WITH CARRY OVER -------------------
  Future<void> _checkAndCarryOverWeek() async {
    final now = DateTime.now();
    final currentWeek = _getWeekNumber(now);
    final currentYear = now.year;

    try {
      final data = await supabase
          .from('weekly_lists')
          .select()
          .eq('family_group_id', widget.currentUser.familyGroupId ?? '')
          .eq('status', 'active');

      if ((data as List).isEmpty) return;
      final activeList = data.first;

      // If the active week is old, mark completed & carry over unchecked
      if (activeList['week_number'] != currentWeek ||
          activeList['year'] != currentYear) {
        // Mark previous week as completed
        await supabase
            .from('weekly_lists')
            .update({'status': 'completed'})
            .eq('id', activeList['id']);

        // Carry over unchecked items
        final uncheckedItems = (activeList['items'] as List)
            .map((e) => Item.fromJson(e))
            .where((i) => !i.isDone)
            .toList();

        if (uncheckedItems.isNotEmpty && mounted) {
          final carryOver = await Navigator.push<List<Item>>(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CarryOverScreen(uncheckedItems: uncheckedItems),
            ),
          );

          if (carryOver != null && carryOver.isNotEmpty) {
            for (var item in carryOver) {
              await addItem(item);
            }
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "Week ${activeList['week_number']} auto-completed.")),
          );
        }
      }
    } catch (e) {
      // Ignore errors in background task
    }
  }

  Future<void> finishWeek() async {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No items to finish.")));
      return;
    }

    final now = DateTime.now();
    final weekNumber = _getWeekNumber(now);
    final listId = const Uuid().v4();

    // Save weekly list
    await supabase.from('weekly_lists').insert({
      'id': listId,
      'name': 'Week $weekNumber, ${now.year}',
      'week_number': weekNumber,
      'year': now.year,
      'status': 'active',
      'family_group_id': widget.currentUser.familyGroupId,
      'start_date': _getStartOfWeek(now).toIso8601String(),
      'end_date': _getEndOfWeek(now).toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
    });

    // Clear items
    for (var item in items) {
      await supabase.from('items').delete().eq('id', item.id);
    }

    setState(() => items.clear());
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Weekly list saved.")));
    }
  }

  int _getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final daysPassed = date.difference(startOfYear).inDays;
    return ((daysPassed + startOfYear.weekday) / 7).ceil();
  }

  DateTime _getStartOfWeek(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  DateTime _getEndOfWeek(DateTime date) =>
      date.add(Duration(days: 7 - date.weekday));

  // ------------------- ADD / TOGGLE / DELETE -------------------
  Future<void> addItem(Item item) async {
    try {
      await supabase.from('items').insert({
        'id': item.id,
        'name': item.name,
        'quantity': item.quantity,
        'category': item.category,
        'added_by': item.addedBy,
        'is_done': item.isDone,
        'family_group_id': widget.currentUser.familyGroupId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  Future<void> deleteItem(Item item) async {
    try {
      await supabase.from('items').delete().eq('id', item.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _quickAddItem(String name) {
    final recent = items.lastWhere(
        (i) => i.name == name,
        orElse: () => Item(
              id: const Uuid().v4(),
              name: name,
              quantity: 1,
              category: 'Other',
              addedBy: widget.currentUser.name,
            ));
    addItem(recent);
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'Fruits':
        return Colors.red;
      case 'Vegetables':
        return Colors.green;
      case 'Dairy':
        return Colors.blue;
      case 'Bakery':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Family Shopping List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            tooltip: 'Family code',
            onPressed: () {
              final family = FamilyService()
                  .cachedFamily(widget.currentUser.familyGroupId);
              if (family != null) showFamilyCodeDialog(context, family);
            },
          ),
          IconButton(
            icon: Icon(themeProvider.isDarkMode
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (items.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    color: Colors.blue.shade50,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: items.map((i) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => _quickAddItem(i.name),
                              child: Chip(
                                label: Text(i.name),
                                backgroundColor: _getCategoryColor(i.category),
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Text(
                            "No items yet — tap + to add",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        )
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (_, index) {
                            final item = items[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: ListTile(
                                title: Text(
                                  item.name,
                                  style: TextStyle(
                                      decoration: item.isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                subtitle: Text(
                                    "Quantity: ${item.quantity} • Added by: ${item.addedBy}"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: item.isDone,
                                      onChanged: (_) => toggleItemDone(item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => deleteItem(item),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addItem',
            child: const Icon(Icons.add),
            onPressed: () async {
              final newItem = await Navigator.push<Item?>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddItemScreen(currentUser: widget.currentUser),
                ),
              );
              // AddItemScreen already saved to Supabase, just reload the list
              if (newItem != null && mounted) {
                _fetchItems();  // Refresh list from Supabase
              }
            },
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'finishWeek',
            child: const Icon(Icons.done_all),
            onPressed: finishWeek,
          ),
        ],
      ),
    );
  }
}
