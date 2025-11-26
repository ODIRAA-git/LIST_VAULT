import 'dart:math';
import 'package:hive/hive.dart';

part 'family_group.g.dart';

@HiveType(typeId: 5)
class FamilyGroup extends HiveObject {
  @HiveField(0)
  String groupId;

  @HiveField(1)
  String groupName;

  @HiveField(2)
  List<String> memberIds; // List of user IDs in this family

  @HiveField(3)
  String createdBy; // User ID who created the group

  @HiveField(4)
  DateTime createdDate;

  @HiveField(5)
  int maxMembers; // Maximum 5 or more members

  @HiveField(6)
  String joinCode; // Short 6-character family join code

  FamilyGroup({
    required this.groupId,
    required this.groupName,
    required this.memberIds,
    required this.createdBy,
    required this.createdDate,
    this.maxMembers = 5,
    required this.joinCode,
  });

  // ------------------------------------------------------------
  // SHORT CODE GENERATION
  // ------------------------------------------------------------
  static String generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; 
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  // Regenerate code (admin only should use this)
  void regenerateJoinCode() {
    joinCode = FamilyGroup.generateJoinCode();
    save();
  }

  // ------------------------------------------------------------
  // MEMBER LOGIC
  // ------------------------------------------------------------
  bool isFull() => memberIds.length >= maxMembers;

  bool addMember(String userId) {
    if (isFull()) return false;
    if (memberIds.contains(userId)) return false;
    memberIds.add(userId);
    save();
    return true;
  }

  bool removeMember(String userId) {
    final removed = memberIds.remove(userId);
    if (removed) save();
    return removed;
  }

  int getMemberCount() => memberIds.length;
}
