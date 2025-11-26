import 'package:hive/hive.dart';
import 'item.dart';

part 'event_list.g.dart';

@HiveType(typeId: 2)
class EventList extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<Item> items;

  EventList({required this.name, required this.items});
}
