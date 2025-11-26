import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/custom_list.dart';
import '../models/item.dart';
import 'add_item_screen.dart';

class CustomListsScreen extends StatefulWidget {
  const CustomListsScreen({super.key});

  @override
  State<CustomListsScreen> createState() => _CustomListsScreenState();
}

class _CustomListsScreenState extends State<CustomListsScreen> {
  late Box<CustomList> customBox;

  @override
  void initState() {
    super.initState();
    customBox = Hive.box<CustomList>('customLists');
  }

  void addCustomList(String name) {
    final newCustom = CustomList(name: name, items: []);
    customBox.add(newCustom);
  }

  void deleteCustomList(int index) {
    customBox.getAt(index)!.delete();
  }

  void addItemToCustom(int listIndex, Item item) {
    final list = customBox.getAt(listIndex)!;
    list.items.add(item);
    list.save();
  }

  void toggleItemDone(int listIndex, int itemIndex) {
    final list = customBox.getAt(listIndex)!;
    final item = list.items[itemIndex];
    item.isDone = !item.isDone;
    list.save();
  }

  void deleteItemFromCustom(int listIndex, int itemIndex) {
    final list = customBox.getAt(listIndex)!;
    list.items.removeAt(itemIndex);
    list.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Custom Lists")),
      body: ValueListenableBuilder<Box<CustomList>>(
        valueListenable: customBox.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) return const Center(child: Text("No custom lists yet."));
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final list = box.getAt(index)!;
              return ExpansionTile(
                title: Text(list.name),
                children: [
                  ...list.items.asMap().entries.map((entry) {
                    int i = entry.key;
                    Item item = entry.value;
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('Quantity: ${item.quantity}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: item.isDone,
                            onChanged: (_) => setState(() => toggleItemDone(index, i)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => setState(() => deleteItemFromCustom(index, i)),
                          ),
                        ],
                      ),
                    );
                  }),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          final newItem = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddItemScreen()),
                          );
                          if (newItem != null) setState(() => addItemToCustom(index, newItem));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => setState(() => deleteCustomList(index)),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final controller = TextEditingController();
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("New Custom List"),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: "List name"),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () {
                    addCustomList(controller.text);
                    Navigator.pop(context);
                  },
                  child: const Text("Add"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
