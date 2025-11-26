import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemTile extends StatelessWidget {
  final Item item;
  final Function(bool?) onChanged;

  const ItemTile({super.key, required this.item, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        item.name,
        style: TextStyle(
            decoration: item.isDone ? TextDecoration.lineThrough : null),
      ),
      subtitle: Text('Quantity: ${item.quantity}'),
      trailing: Checkbox(
        value: item.isDone,
        onChanged: onChanged,
      ),
    );
  }
}
