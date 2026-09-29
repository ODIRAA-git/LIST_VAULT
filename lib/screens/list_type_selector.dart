import 'package:flutter/material.dart';
import 'family_setup_screen.dart';
import 'event_list_screen.dart';
import 'custom_lists_screen.dart';

class ListTypeSelectorScreen extends StatelessWidget {
  const ListTypeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
              Colors.pink.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Navbar
              _buildNavbar(context),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Welcome Section
                      _buildWelcomeSection(),

                      const SizedBox(height: 24),

                      // Recruiter / reviewer shortcut
                      _buildDemoBanner(context),

                      const SizedBox(height: 32),

                      // List Type Cards
                      _buildListTypeCard(
                        context,
                        title: "Weekly Shopping List",
                        subtitle: "Plan your weekly groceries with family",
                        icon: Icons.shopping_cart_rounded,
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FamilySetupScreen()),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildListTypeCard(
                        context,
                        title: "Event List",
                        subtitle: "Organize special occasions and events",
                        icon: Icons.celebration_rounded,
                        gradient: LinearGradient(
                          colors: [Colors.green.shade400, Colors.green.shade600],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EventListScreen()),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildListTypeCard(
                        context,
                        title: "Custom List",
                        subtitle: "Create personalized lists for anything",
                        icon: Icons.list_alt_rounded,
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade400, Colors.orange.shade600],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CustomListsScreen()),
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      // Features Section
                      _buildFeaturesSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App Name with Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "List Vault",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          // Login Button
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FamilySetupScreen()),
              );
            },
            icon: const Icon(Icons.login_rounded, size: 20),
            label: const Text("Login"),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome to List Vault",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Organize your life with smart lists. Choose a list type to get started.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDemoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.purple.shade500],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recruiter or reviewer?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Try a pre-filled family list in one tap, then join it from your "
            "phone with the code to see real-time collaboration.",
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FamilySetupScreen(startDemo: true),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text("Try the demo"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTypeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, color: Colors.amber.shade600, size: 24),
              const SizedBox(width: 8),
              const Text(
                "Why List Vault?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            Icons.sync_rounded,
            "Real-time Sync",
            "Keep your lists synchronized across devices",
          ),
          _buildFeatureItem(
            Icons.people_rounded,
            "Family Sharing",
            "Collaborate with family members on shared lists",
          ),
          _buildFeatureItem(
            Icons.offline_bolt_rounded,
            "Offline Mode",
            "Access your lists even without internet",
          ),
          _buildFeatureItem(
            Icons.security_rounded,
            "Secure Storage",
            "Your data is safely encrypted and stored",
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.blue.shade600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
