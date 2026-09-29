import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:uuid/uuid.dart';

import '../models/family_group.dart';
import '../models/user.dart';

class FamilyException implements Exception {
  final String message;
  FamilyException(this.message);

  @override
  String toString() => message;
}

/// Families live in Supabase so they can be joined from any device.
/// A copy is cached in Hive so each device remembers the families it has joined.
class FamilyService {
  /// Creating a family with this name gives reviewers a pre-filled demo group.
  static const demoFamilyName = 'demo@listvault.com';

  final SupabaseClient _supabase = Supabase.instance.client;
  final Box<FamilyGroup> _familyGroupBox = Hive.box<FamilyGroup>(
    'familyGroups',
  );
  final Box<User> _userBox = Hive.box<User>('users');

  static bool isDemoFamily(String name) =>
      name.trim().toLowerCase() == demoFamilyName;

  Future<(FamilyGroup, User)> createFamily({
    required String familyName,
    required String userName,
    required String avatarColor,
  }) async {
    final groupId = const Uuid().v4();
    final userId = const Uuid().v4();

    // Retry in the unlikely case the random join code is already taken
    String? joinCode;
    for (var attempt = 0; attempt < 3 && joinCode == null; attempt++) {
      final candidate = FamilyGroup.generateJoinCode();
      try {
        await _supabase.from('family_groups').insert({
          'id': groupId,
          'name': familyName,
          'join_code': candidate,
          'created_by': userId,
          'max_members': 10,
        });
        joinCode = candidate;
      } on PostgrestException catch (e) {
        if (e.code != '23505') throw _friendly(e); // 23505 = unique violation
      }
    }
    if (joinCode == null) {
      throw FamilyException('Could not create family. Please try again.');
    }

    await _insertMember(userId, groupId, userName, avatarColor);

    final family = FamilyGroup(
      groupId: groupId,
      groupName: familyName,
      memberIds: [userId],
      createdBy: userId,
      createdDate: DateTime.now(),
      maxMembers: 10,
      joinCode: joinCode,
    );
    final user = User(
      id: userId,
      name: userName,
      familyGroupId: groupId,
      avatarColor: avatarColor,
    );
    await _cache(family, user);

    if (isDemoFamily(familyName)) {
      await _seedDemoItems(groupId);
    }

    return (family, user);
  }

  /// Joins by short join code (or the full family ID shared by older versions).
  /// Joining with a name that is already a member re-enters as that member.
  Future<(FamilyGroup, User)> joinFamily({
    required String code,
    required String userName,
    required String avatarColor,
  }) async {
    final Map<String, dynamic>? row;
    try {
      row =
          await _supabase
              .from('family_groups')
              .select()
              .eq('join_code', code.toUpperCase())
              .maybeSingle() ??
          await _supabase
              .from('family_groups')
              .select()
              .eq('id', code)
              .maybeSingle();
    } on PostgrestException catch (e) {
      throw _friendly(e);
    }
    if (row == null) {
      throw FamilyException('Family not found. Please check the code.');
    }

    final groupId = row['id'] as String;
    final maxMembers = (row['max_members'] as int?) ?? 10;
    final members = List<Map<String, dynamic>>.from(
      await _supabase
          .from('family_members')
          .select()
          .eq('family_group_id', groupId),
    );

    final existing = members.where(
      (m) => (m['name'] as String).toLowerCase() == userName.toLowerCase(),
    );

    final User user;
    if (existing.isNotEmpty) {
      final m = existing.first;
      user = User(
        id: m['id'],
        name: m['name'],
        familyGroupId: groupId,
        avatarColor: m['avatar_color'],
      );
    } else {
      if (members.length >= maxMembers) {
        throw FamilyException('Family is full ($maxMembers members max)');
      }
      final userId = const Uuid().v4();
      await _insertMember(userId, groupId, userName, avatarColor);
      members.add({'id': userId});
      user = User(
        id: userId,
        name: userName,
        familyGroupId: groupId,
        avatarColor: avatarColor,
      );
    }

    final family = FamilyGroup(
      groupId: groupId,
      groupName: row['name'],
      memberIds: members.map((m) => m['id'] as String).toList(),
      createdBy: row['created_by'],
      createdDate: DateTime.tryParse(row['created_at'] ?? '') ?? DateTime.now(),
      maxMembers: maxMembers,
      joinCode: row['join_code'],
    );
    await _cache(family, user);
    return (family, user);
  }

  /// Families this device has joined before, newest first, for quick re-entry.
  List<(FamilyGroup, User)> savedSessions() {
    final sessions = <(FamilyGroup, User)>[];
    for (final user in _userBox.values.toList().reversed) {
      final family = cachedFamily(user.familyGroupId);
      if (family != null) sessions.add((family, user));
    }
    return sessions;
  }

  FamilyGroup? cachedFamily(String? groupId) {
    for (final g in _familyGroupBox.values) {
      if (g.groupId == groupId) return g;
    }
    return null;
  }

  Future<void> _insertMember(
    String id,
    String groupId,
    String name,
    String avatarColor,
  ) async {
    try {
      await _supabase.from('family_members').insert({
        'id': id,
        'family_group_id': groupId,
        'name': name,
        'avatar_color': avatarColor,
      });
    } on PostgrestException catch (e) {
      throw _friendly(e);
    }
  }

  Future<void> _cache(FamilyGroup family, User user) async {
    final oldFamily = _familyGroupBox.values
        .where((g) => g.groupId == family.groupId)
        .toList();
    for (final g in oldFamily) {
      await g.delete();
    }
    await _familyGroupBox.add(family);

    if (!_userBox.values.any((u) => u.id == user.id)) {
      await _userBox.add(user);
    }
  }

  Future<void> _seedDemoItems(String groupId) async {
    const samples = [
      ('Apples', 6, 'Fruits', 'Mum', false),
      ('Spinach', 1, 'Vegetables', 'Dad', false),
      ('Milk', 2, 'Dairy', 'Mum', true),
      ('Sourdough bread', 1, 'Bakery', 'Ada', false),
      ('Bananas', 4, 'Fruits', 'Ada', true),
      ('Greek yoghurt', 3, 'Dairy', 'Dad', false),
    ];
    final now = DateTime.now();
    try {
      await _supabase.from('items').insert([
        for (var i = 0; i < samples.length; i++)
          {
            'id': const Uuid().v4(),
            'name': samples[i].$1,
            'quantity': samples[i].$2,
            'category': samples[i].$3,
            'added_by': samples[i].$4,
            'is_done': samples[i].$5,
            'family_group_id': groupId,
            'created_at': now.add(Duration(seconds: i)).toIso8601String(),
          },
      ]);
    } catch (_) {
      // Sample data is a nice-to-have; the demo group still works without it
    }
  }

  FamilyException _friendly(PostgrestException e) {
    if (e.code == 'PGRST205' || e.code == '42P01') {
      return FamilyException(
        'Family storage is not set up yet (run supabase_family_groups.sql).',
      );
    }
    return FamilyException('Network error: ${e.message}');
  }
}
