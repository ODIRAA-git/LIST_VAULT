import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/weekly_list.dart';

class WeeklyListsScreen extends StatelessWidget {
  const WeeklyListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weeklyListBox = Hive.box<WeeklyList>('weeklyLists');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Lists'),
      ),
      body: ValueListenableBuilder<Box<WeeklyList>>(
        valueListenable: weeklyListBox.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('No weekly lists saved yet.'),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final weeklyList = box.getAt(index)!;

              // ---------- DEBUG LOG ----------
              print('=== DEBUG WEEKLY LIST ===');
              print('List ID: ${weeklyList.id}');
              print('List Name: ${weeklyList.name}');
              print('Family Group ID: ${weeklyList.familyGroupId}');
              for (var item in weeklyList.items) {
                print('Item: ${item.name} | ID: ${item.id} | Done: ${item.isDone}');
              }
              print('============================');

              return ExpansionTile(
                title: Text(weeklyList.name),
                children: weeklyList.items.map((item) {
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('Quantity: ${item.quantity}'),
                    trailing: Icon(
                      item.isDone ? Icons.check_circle : Icons.circle_outlined,
                      color: item.isDone ? Colors.green : null,
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
