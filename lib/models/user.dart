import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 4)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? familyGroupId; // Links user to a family group

  @HiveField(3)
  String? avatarColor; // For visual identification (optional)

  @HiveField(4)
  DateTime? joinedDate;

  User({
    required this.id,
    required this.name,
    this.familyGroupId,
    this.avatarColor,
    DateTime? joinedDate,
  }) : joinedDate = joinedDate ?? DateTime.now();
}
