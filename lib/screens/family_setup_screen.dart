import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/family_group.dart';
import '../models/user.dart';
import 'home_screen.dart';

class FamilySetupScreen extends StatefulWidget {
  const FamilySetupScreen({super.key});

  @override
  State<FamilySetupScreen> createState() => _FamilySetupScreenState();
}

class _FamilySetupScreenState extends State<FamilySetupScreen> {
  final _familyNameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _joinCodeController = TextEditingController();
  bool isCreatingFamily = true;

  late Box<FamilyGroup> familyGroupBox;
  late Box<User> userBox;

  @override
  void initState() {
    super.initState();
    familyGroupBox = Hive.box<FamilyGroup>('familyGroups');
    userBox = Hive.box<User>('users');
  }

  @override
  void dispose() {
    _familyNameController.dispose();
    _userNameController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }

  void createFamily() {
    final familyName = _familyNameController.text.trim();
    final userName = _userNameController.text.trim();

    if (familyName.isEmpty || userName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    // Create new family group
    final groupId = const Uuid().v4();
    final userId = const Uuid().v4();

    final newFamily = FamilyGroup(
      groupId: groupId,
      groupName: familyName,
      memberIds: [userId],
      createdBy: userId,
      createdDate: DateTime.now(),
      maxMembers: 10, // Allow up to 10 members
      joinCode: FamilyGroup.generateJoinCode(),
    );

    final newUser = User(
      id: userId,
      name: userName,
      familyGroupId: groupId,
      avatarColor: _getRandomColor(),
    );

    familyGroupBox.add(newFamily);
    userBox.add(newUser);

    // Show family code dialog
    _showFamilyCodeDialog(groupId, newUser);
  }

  void joinFamily() {
    final joinCode = _joinCodeController.text.trim();
    final userName = _userNameController.text.trim();

    if (joinCode.isEmpty || userName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    // Find family by group ID
    final family = familyGroupBox.values.firstWhere(
      (group) => group.groupId == joinCode,
      orElse: () => FamilyGroup(
        groupId: '',
        groupName: '',
        memberIds: [],
        createdBy: '',
        createdDate: DateTime.now(),
        joinCode: '',
      ),
    );

    if (family.groupId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Family not found. Please check the code.")),
      );
      return;
    }

    if (family.isFull()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Family is full (${family.maxMembers} members max)")),
      );
      return;
    }

    // Create new user and add to family
    final userId = const Uuid().v4();
    final newUser = User(
      id: userId,
      name: userName,
      familyGroupId: family.groupId,
      avatarColor: _getRandomColor(),
    );

    family.addMember(userId);
    family.save();
    userBox.add(newUser);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(currentUser: newUser)),
    );
  }

  void _showFamilyCodeDialog(String groupId, User user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Family Created!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Share this code with family members to join:"),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: SelectableText(
                groupId,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen(currentUser: user)),
              );
            },
            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }

  String _getRandomColor() {
    final colors = [
      '#FF5733', '#33FF57', '#3357FF', '#FF33A1',
      '#A133FF', '#FF8C33', '#33FFF5', '#F533FF'
    ];
    colors.shuffle();
    return colors.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade400, Colors.purple.shade400],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Back to home',
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Icon(
                  Icons.people_rounded,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Family Setup",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Create or join a family group",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),

                // Toggle buttons
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildToggleButton(
                          "Create Family",
                          isCreatingFamily,
                          () => setState(() => isCreatingFamily = true),
                        ),
                      ),
                      Expanded(
                        child: _buildToggleButton(
                          "Join Family",
                          !isCreatingFamily,
                          () => setState(() => isCreatingFamily = false),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Form card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isCreatingFamily) ...[
                        _buildTextField(
                          controller: _familyNameController,
                          label: "Family Name",
                          hint: "e.g., Smith Family",
                          icon: Icons.home_rounded,
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        _buildTextField(
                          controller: _joinCodeController,
                          label: "Family Code",
                          hint: "Enter family code",
                          icon: Icons.qr_code_rounded,
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildTextField(
                        controller: _userNameController,
                        label: "Your Name",
                        hint: "e.g., John",
                        icon: Icons.person_rounded,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isCreatingFamily ? createFamily : joinFamily,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isCreatingFamily ? "Create Family" : "Join Family",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.blue.shade600 : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
      ),
    );
  }
}
