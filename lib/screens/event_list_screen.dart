import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/event_list.dart';
import '../models/item.dart';
import 'add_item_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  late Box<EventList> eventBox;

  @override
  void initState() {
    super.initState();
    eventBox = Hive.box<EventList>('eventLists');
  }

  void addEventList(String name) {
    final newEvent = EventList(name: name, items: []);
    eventBox.add(newEvent);
  }

  void deleteEventList(int index) {
    eventBox.getAt(index)!.delete();
  }

  void addItemToEvent(int eventIndex, Item item) {
    final event = eventBox.getAt(eventIndex)!;
    event.items.add(item);
    event.save();
  }

  void toggleItemDone(int eventIndex, int itemIndex) {
    final event = eventBox.getAt(eventIndex)!;
    final item = event.items[itemIndex];
    item.isDone = !item.isDone;
    event.save();
  }

  void deleteItemFromEvent(int eventIndex, int itemIndex) {
    final event = eventBox.getAt(eventIndex)!;
    event.items.removeAt(itemIndex);
    event.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Event Lists")),
      body: ValueListenableBuilder<Box<EventList>>(
        valueListenable: eventBox.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) return const Center(child: Text("No events yet."));
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final event = box.getAt(index)!;
              return ExpansionTile(
                title: Text(event.name),
                children: [
                  ...event.items.asMap().entries.map((entry) {
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
                            onPressed: () => setState(() => deleteItemFromEvent(index, i)),
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
                          if (newItem != null) setState(() => addItemToEvent(index, newItem));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => setState(() => deleteEventList(index)),
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
              title: const Text("New Event List"),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: "Event name"),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () {
                    addEventList(controller.text);
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
