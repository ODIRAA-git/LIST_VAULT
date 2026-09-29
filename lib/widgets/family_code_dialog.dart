import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/family_group.dart';
import '../services/family_service.dart';

Future<void> showFamilyCodeDialog(
  BuildContext context,
  FamilyGroup family, {
  String title = "Family Code",
  String actionLabel = "Close",
}) {
  final isDemo = FamilyService.isDemoFamily(family.groupName);

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Share this code with family members to join from any device:",
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    family.joinCode,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 4,
                      color: Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.blue),
                  tooltip: 'Copy code',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: family.joinCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Code copied")),
                    );
                  },
                ),
              ],
            ),
          ),
          if (isDemo) ...[
            const SizedBox(height: 16),
            Text(
              "Try the collaboration: open List Vault on another device or "
              "browser, choose Join Family, and enter this code with any "
              "name. Items you add appear on both screens in real time.",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(actionLabel),
        ),
      ],
    ),
  );
}
