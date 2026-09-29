import 'package:flutter/material.dart';
import '../models/family_group.dart';
import '../models/user.dart';
import '../services/family_service.dart';
import '../widgets/family_code_dialog.dart';
import 'home_screen.dart';

class FamilySetupScreen extends StatefulWidget {
  /// When true, immediately starts the guest demo (used by the homepage banner).
  final bool startDemo;

  const FamilySetupScreen({super.key, this.startDemo = false});

  @override
  State<FamilySetupScreen> createState() => _FamilySetupScreenState();
}

class _FamilySetupScreenState extends State<FamilySetupScreen> {
  final _familyNameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _joinCodeController = TextEditingController();
  bool isCreatingFamily = true;
  bool isLoading = false;

  final _familyService = FamilyService();

  @override
  void initState() {
    super.initState();
    if (widget.startDemo) {
      WidgetsBinding.instance.addPostFrameCallback((_) => continueAsGuest());
    }
  }

  @override
  void dispose() {
    _familyNameController.dispose();
    _userNameController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }

  Future<void> createFamily() async {
    final familyName = _familyNameController.text.trim();
    final userName = _userNameController.text.trim();

    if (familyName.isEmpty || userName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    final result = await _run(
      () => _familyService.createFamily(
        familyName: familyName,
        userName: userName,
        avatarColor: _getRandomColor(),
      ),
    );
    if (result == null || !mounted) return;

    final (family, user) = result;
    await showFamilyCodeDialog(
      context,
      family,
      title: "Family Created!",
      actionLabel: "Continue",
    );
    _openHome(user);
  }

  Future<void> joinFamily() async {
    final joinCode = _joinCodeController.text.trim();
    final userName = _userNameController.text.trim();

    if (joinCode.isEmpty || userName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    final result = await _run(
      () => _familyService.joinFamily(
        code: joinCode,
        userName: userName,
        avatarColor: _getRandomColor(),
      ),
    );
    if (result == null || !mounted) return;
    _openHome(result.$2);
  }

  // Recruiter/reviewer shortcut: creates a demo family (pre-filled with
  // sample items) exactly as if "demo@listvault.com" was typed as the name.
  void continueAsGuest() {
    setState(() => isCreatingFamily = true);
    _familyNameController.text = FamilyService.demoFamilyName;
    if (_userNameController.text.trim().isEmpty) {
      _userNameController.text = "Reviewer";
    }
    createFamily();
  }

  Future<T?> _run<T>(Future<T> Function() action) async {
    setState(() => isLoading = true);
    try {
      return await action();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is FamilyException
                  ? e.message
                  : "Couldn't reach the server. Check your connection.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _openHome(User user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(currentUser: user)),
    );
  }

  String _getRandomColor() {
    final colors = [
      '#FF5733',
      '#33FF57',
      '#3357FF',
      '#FF33A1',
      '#A133FF',
      '#FF8C33',
      '#33FFF5',
      '#F533FF',
    ];
    colors.shuffle();
    return colors.first;
  }

  @override
  Widget build(BuildContext context) {
    final savedSessions = _familyService.savedSessions();

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
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Back to home',
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Icon(Icons.people_rounded, size: 80, color: Colors.white),
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
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 40),

                // Families this device has joined before
                if (savedSessions.isNotEmpty) ...[
                  _buildSavedSessions(savedSessions),
                  const SizedBox(height: 24),
                ],

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
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : (isCreatingFamily
                                        ? createFamily
                                        : joinFamily),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      isCreatingFamily
                                          ? "Create Family"
                                          : "Join Family",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading ? null : continueAsGuest,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue.shade600,
                                side: BorderSide(color: Colors.blue.shade600),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Continue as Guest",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Recruiter or reviewer? Create a family named "
                  "demo@listvault.com (or tap \"Continue as Guest\") to get a "
                  "sample list and a code to rejoin from any device under any name.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedSessions(List<(FamilyGroup, User)> sessions) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Continue where you left off",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (final (family, user) in sessions)
            Card(
              margin: const EdgeInsets.only(top: 8),
              child: ListTile(
                leading: const Icon(Icons.group_rounded),
                title: Text(family.groupName),
                subtitle: Text("as ${user.name} · code ${family.joinCode}"),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: isLoading ? null : () => _openHome(user),
              ),
            ),
        ],
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
      ),
    );
  }
}
