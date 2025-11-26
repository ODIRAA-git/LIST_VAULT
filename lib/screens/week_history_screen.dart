import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/weekly_list.dart';
import '../models/user.dart';
import 'week_detail_screen.dart';

class WeekHistoryScreen extends StatelessWidget {
  final User currentUser;

  const WeekHistoryScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final weeklyListBox = Hive.box<WeeklyList>('weeklyLists');
    final familyId = currentUser.familyGroupId ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Week History"),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<Box<WeeklyList>>(
        valueListenable: weeklyListBox.listenable(),
        builder: (context, box, _) {
          // Filter lists for current family and sort by date (newest first)
          final familyLists = box.values
              .where((list) => list.familyGroupId == familyId)
              .toList()
            ..sort((a, b) => b.startDate.compareTo(a.startDate));

          if (familyLists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No weekly lists yet",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Start adding items and create your first week!",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: familyLists.length,
            itemBuilder: (context, index) {
              final weeklyList = familyLists[index];
              return _buildWeekCard(context, weeklyList);
            },
          );
        },
      ),
    );
  }

  Widget _buildWeekCard(BuildContext context, WeeklyList weeklyList) {
    final isActive = weeklyList.isActive();
    final isCompleted = weeklyList.isCompleted();
    final completionPercentage = weeklyList.getCompletionPercentage();

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isActive) {
      statusColor = Colors.green;
      statusIcon = Icons.play_circle_outline;
      statusText = "Active";
    } else if (isCompleted) {
      statusColor = Colors.blue;
      statusIcon = Icons.check_circle_outline;
      statusText = "Completed";
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.archive_outlined;
      statusText = "Archived";
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive ? Colors.green.shade200 : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WeekDetailScreen(weeklyList: weeklyList),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Week title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weeklyList.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${_formatDate(weeklyList.startDate)} - ${_formatDate(weeklyList.endDate)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Completion",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "${completionPercentage.toStringAsFixed(0)}%",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: completionPercentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      color: completionPercentage == 100
                          ? Colors.green
                          : Colors.blue.shade600,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Item count
              Row(
                children: [
                  Icon(Icons.shopping_cart, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    "${weeklyList.items.length} items",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
                  const SizedBox(width: 6),
                  Text(
                    "${weeklyList.items.where((item) => item.isDone).length} done",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}";
  }
}
