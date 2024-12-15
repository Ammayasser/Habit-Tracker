import 'package:flutter/material.dart';
import '../models/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HabitsProvider with ChangeNotifier {
  List<Habit> _habits = [];
  static const String _storageKey = 'habits';
  late SharedPreferences _prefs;

  HabitsProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    loadHabits();
  }

  List<Habit> get habits => [..._habits];

  Future<void> loadHabits() async {
    final habitsJson = _prefs.getStringList(_storageKey);
    if (habitsJson != null && habitsJson.isNotEmpty) {
      _habits = habitsJson
          .map((habitStr) => Habit.fromJson(json.decode(habitStr)))
          .toList();
    } else {
      // Add default habits for first time users
      _habits = [
        Habit(
          id: 'default_meditation',
          title: 'Meditation',
          hasReminder: false,
          color: const Color(0xFFFFB74D),
          weekProgress: List.generate(7, (_) => false),
        ),
        Habit(
          id: 'default_reading',
          title: 'Reading',
          hasReminder: false,
          color: const Color(0xFF4FC3F7),
          weekProgress: List.generate(7, (_) => false),
        ),
      ];
      // Save the default habits
      await _saveHabits();
    }
    notifyListeners();
  }

  Future<void> _saveHabits() async {
    final habitsJson = _habits
        .map((habit) => json.encode(habit.toJson()))
        .toList();
    await _prefs.setStringList(_storageKey, habitsJson);
  }

  void toggleHabitDay(String habitId, int dayIndex) {
    final habitIndex = _habits.indexWhere((habit) => habit.id == habitId);
    if (habitIndex != -1) {
      _habits[habitIndex].weekProgress[dayIndex] = !_habits[habitIndex].weekProgress[dayIndex];
      _saveHabits();
      notifyListeners();
    }
  }

  void toggleReminder(String habitId) {
    final habitIndex = _habits.indexWhere((habit) => habit.id == habitId);
    if (habitIndex != -1) {
      _habits[habitIndex].hasReminder = !_habits[habitIndex].hasReminder;
      _saveHabits();
      notifyListeners();
    }
  }

  void addHabit(Habit habit) {
    _habits.add(habit);
    _saveHabits();
    notifyListeners();
  }

  void updateHabit(Habit habit) {
    _saveHabits();
    notifyListeners();
  }

  Future<void> deleteHabit(Habit habit) async {
    _habits.removeWhere((h) => h.id == habit.id);
    await _saveHabits();
    notifyListeners();
  }

  static const List<Color> availableColors = [
    Color(0xFFFFB74D), // Orange
    Color(0xFF4FC3F7), // Light Blue
    Color(0xFF81C784), // Green
    Color(0xFFE57373), // Red
    Color(0xFF9575CD), // Purple
    Color(0xFF4DB6AC), // Teal
    Color(0xFFFFD54F), // Amber
    Color(0xFF7986CB), // Indigo
  ];
}
