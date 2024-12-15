import 'package:flutter/material.dart';
import 'dart:convert';

class Habit {
  final String id;
  final String title;
  bool hasReminder;
  final Color color;
  final IconData icon;
  List<bool> weekProgress;
  TimeOfDay? reminderTime;
  Map<String, bool> completionHistory;

  Habit({
    required this.id,
    required this.title,
    this.hasReminder = false,
    required this.color,
    this.icon = Icons.check_circle_outline,
    required this.weekProgress,
    this.reminderTime,
    Map<String, bool>? completionHistory,
  }) : completionHistory = completionHistory ?? {};

  // Helper method to format date key
  static String formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Check if a specific date is completed
  bool isDateCompleted(DateTime date) {
    final key = formatDateKey(date);
    return completionHistory[key] ?? false;
  }

  // Toggle completion status for a date
  void toggleCompletion(DateTime date) {
    final key = formatDateKey(date);
    completionHistory[key] = !(completionHistory[key] ?? false);
  }

  // Get completion rate for the habit
  double get completionRate {
    if (completionHistory.isEmpty) return 0.0;
    final completed = completionHistory.values.where((v) => v).length;
    return completed / completionHistory.length;
  }

  // Calculate current streak
  int get currentStreak {
    int streak = 0;
    final now = DateTime.now();
    DateTime currentDate = now;

    // Go backwards from today until we find a day that wasn't completed
    while (true) {
      if (!isDateCompleted(currentDate)) break;
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  // Calculate best streak
  int get bestStreak {
    if (completionHistory.isEmpty) return 0;

    int currentStreak = 0;
    int maxStreak = 0;
    final sortedDates = completionHistory.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    DateTime? previousDate;

    for (final dateStr in sortedDates) {
      if (!completionHistory[dateStr]!) {
        currentStreak = 0;
        continue;
      }

      final dateParts = dateStr.split('-');
      final currentDate = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );

      if (previousDate != null) {
        final difference = currentDate.difference(previousDate).inDays;
        if (difference == 1) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
      } else {
        currentStreak = 1;
      }

      maxStreak = maxStreak < currentStreak ? currentStreak : maxStreak;
      previousDate = currentDate;
    }

    return maxStreak;
  }

  // Convert Habit to Map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'hasReminder': hasReminder,
      'color': color.value,
      'icon': icon.codePoint,
      'weekProgress': weekProgress,
      'reminderTime': reminderTime != null
          ? '${reminderTime!.hour}:${reminderTime!.minute}'
          : null,
      'completionHistory': completionHistory,
    };
  }

  // Create Habit from Map
  factory Habit.fromJson(Map<String, dynamic> json) {
    TimeOfDay? reminderTime;
    if (json['reminderTime'] != null) {
      final parts = json['reminderTime'].split(':');
      reminderTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return Habit(
      id: json['id'],
      title: json['title'],
      hasReminder: json['hasReminder'],
      color: Color(json['color']),
      icon: IconData(json['icon'] ?? Icons.check_circle_outline.codePoint,
          fontFamily: 'MaterialIcons'),
      weekProgress: List<bool>.from(json['weekProgress']),
      reminderTime: reminderTime,
      completionHistory:
          Map<String, bool>.from(json['completionHistory'] ?? {}),
    );
  }
}
