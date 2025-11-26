import 'package:hive/hive.dart';
import 'item.dart';

part 'custom_list.g.dart';

@HiveType(typeId: 3)
class CustomList extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<Item> items;

  CustomList({required this.name, required this.items});
}
