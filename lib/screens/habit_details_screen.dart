import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../services/notification_service.dart';
import '../providers/habits_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class HabitDetailsScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailsScreen({
    super.key,
    required this.habit,
  });

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen>
    with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  late bool _isReminderEnabled;
  String _selectedTimeRange = 'Year';
  late AnimationController _deleteIconController;
  late Animation<double> _deleteIconAnimation;

  @override
  void initState() {
    super.initState();
    _isReminderEnabled = widget.habit.hasReminder;
    if (widget.habit.reminderTime != null) {
      _reminderTime = widget.habit.reminderTime!;
    }

    // Initialize delete icon animation
    _deleteIconController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _deleteIconAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _deleteIconController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _deleteIconController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xFF2A2A2A),
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected)
                      ? widget.habit.color
                      : const Color(0xFF3A3A3A)),
              hourMinuteColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected)
                      ? widget.habit.color
                      : const Color(0xFF3A3A3A)),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: widget.habit.color,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
      if (_isReminderEnabled) {
        await _scheduleNotification();
      }
    }
  }

  Future<void> _toggleReminder(bool value) async {
    setState(() {
      _isReminderEnabled = value;
    });

    if (value) {
      await _selectTime(context);
    } else {
      await _notificationService.cancelHabitReminder(widget.habit.id);
      // Update habit
      widget.habit.hasReminder = false;
      widget.habit.reminderTime = null;
    }
  }

  Future<void> _scheduleNotification() async {
    await _notificationService.scheduleHabitReminder(
      id: widget.habit.id,
      title: widget.habit.title,
      time: _reminderTime,
    );

    // Update habit
    widget.habit.hasReminder = true;
    widget.habit.reminderTime = _reminderTime;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reminder set for ${_reminderTime.format(context)}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: widget.habit.color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildHistorySection() {
    final now = DateTime.now();
    final dates = List.generate(42, (index) {
      return now.subtract(Duration(days: 41 - index));
    });

    final months = dates.fold<Map<int, String>>({}, (map, date) {
      map[date.month] = _getMonthName(date.month);
      return map;
    });

    return _buildSectionCard(
      'History',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(dates.first.day)} ${_getMonthName(dates.first.month)} - ${dates.last.day} ${_getMonthName(dates.last.month)}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Month labels
          Row(
            children: months.values.map((month) {
              return Expanded(
                child: Text(
                  month,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Days grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isToday = date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;
              final isCompleted = widget.habit.isDateCompleted(date);
              final isFutureDate = date.isAfter(now);

              return Tooltip(
                message: '${date.day} ${_getMonthName(date.month)}',
                child: GestureDetector(
                  onTap: isFutureDate
                      ? null
                      : () {
                          setState(() {
                            widget.habit.toggleCompletion(date);
                          });
                          // Save changes through provider
                          context
                              .read<HabitsProvider>()
                              .updateHabit(widget.habit);
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? widget.habit.color.withOpacity(0.8)
                          : const Color(0xFF3A3A3A),
                      borderRadius: BorderRadius.circular(8),
                      border: isToday
                          ? Border.all(
                              color: Colors.white,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : Text(
                              date.day.toString(),
                              style: TextStyle(
                                color: isFutureDate
                                    ? Colors.grey.withOpacity(0.3)
                                    : isToday
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                fontSize: 12,
                                fontWeight: isToday
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                color: widget.habit.color.withOpacity(0.8),
                label: 'Completed',
              ),
              const SizedBox(width: 16),
              _buildLegendItem(
                color: const Color(0xFF3A3A3A),
                label: 'Not Completed',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Widget _buildSectionCard(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.habit.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.habit.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              style: TextStyle(
                color: widget.habit.color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: child,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: widget.habit.color,
            flexibleSpace: FlexibleSpaceBar(
              title: Hero(
                tag: 'habit_title_${widget.habit.id}',
                child: Text(
                  widget.habit.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'habit_color_${widget.habit.id}',
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            widget.habit.color,
                            widget.habit.color.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Hero(
                      tag: 'habit_icon_${widget.habit.id}',
                      child: Icon(
                        widget.habit.icon,
                        size: 200,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              // Delete button
              MouseRegion(
                onEnter: (_) => _deleteIconController.forward(),
                onExit: (_) => _deleteIconController.reverse(),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ScaleTransition(
                    scale: _deleteIconAnimation,
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete_rounded,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => _showDeleteConfirmation(context),
                      tooltip: 'Delete Habit',
                    ),
                  ),
                ),
              ),
              // Reminder toggle
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications,
                      color: _isReminderEnabled ? Colors.white : Colors.white54,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _isReminderEnabled,
                      onChanged: _toggleReminder,
                      activeColor: Colors.white,
                      activeTrackColor: Colors.white.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats Cards
                  _buildSectionCard(
                    'Quick Stats',
                    SizedBox(
                      height: 100,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildQuickStatCard(
                              'Current Streak',
                              '${widget.habit.currentStreak}',
                              Icons.local_fire_department,
                            ),
                            const SizedBox(width: 30),
                            _buildQuickStatCard(
                              'Completion',
                              '${(widget.habit.completionRate * 100).toStringAsFixed(0)}%',
                              Icons.show_chart,
                            ),
                            const SizedBox(width: 30),
                            _buildQuickStatCard(
                              'Best Streak',
                              '${widget.habit.bestStreak}',
                              Icons.emoji_events,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildHistorySection(),
                  const SizedBox(height: 24),
                  _buildStatisticsCard(),
                  const SizedBox(height: 24),
                  // Settings Section
                  _buildSectionCard(
                    'Settings',
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.notifications_outlined,
                        color: widget.habit.color,
                        size: 24,
                      ),
                      title: Text(
                        'Reminder',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        _isReminderEnabled
                            ? 'Daily at ${_reminderTime.format(context)}'
                            : 'Not set',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      trailing: Switch(
                        value: _isReminderEnabled,
                        onChanged: _toggleReminder,
                        activeColor: widget.habit.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(String title, String value, IconData icon) {
    return Container(
      width: 110,
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: widget.habit.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.habit.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: widget.habit.color,
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    // Calculate last 7 days completion data
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      return {
        'date': date,
        'completed': widget.habit.completionHistory[dateStr] ?? false,
      };
    });

    return _buildSectionCard(
      'Statistics',
      Column(
        children: [
          // Weekly Progress Chart
          Container(
            height: 200,
            padding: const EdgeInsets.only(right: 16),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= 7) return const Text('');
                        final date = last7Days[value.toInt()]['date'] as DateTime;
                        return Text(
                          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1],
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        );
                      },
                      reservedSize: 22,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: last7Days.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value['completed'] as bool ? 1 : 0,
                      );
                    }).toList(),
                    isCurved: true,
                    color: widget.habit.color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: widget.habit.color,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: widget.habit.color.withOpacity(0.15),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: const Color(0xFF2A2A2A),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final date = last7Days[spot.x.toInt()]['date'] as DateTime;
                        final completed = last7Days[spot.x.toInt()]['completed'] as bool;
                        return LineTooltipItem(
                          '${date.day}/${date.month}\n${completed ? 'Completed' : 'Missed'}',
                          TextStyle(
                            color: completed ? widget.habit.color : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Success Rate by Day
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDaySuccessRate('This Week', 0.8),
              _buildDaySuccessRate('This Month', 0.65),
              _buildDaySuccessRate('All Time', widget.habit.completionRate),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaySuccessRate(String label, double rate) {
    return Column(
      children: [
        Text(
          '${(rate * 100).toStringAsFixed(0)}%',
          style: TextStyle(
            color: widget.habit.color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container(); // This won't be used
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: AlertDialog(
              backgroundColor: const Color(0xFF2A2A2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Delete Habit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: widget.habit.color,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Are you sure you want to delete "${widget.habit.title}"?',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This action cannot be undone.',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black87,
    );

    if (result == true) {
      // Show a loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const CircularProgressIndicator(),
          ),
        ),
      );

      // Delete the habit
      await context.read<HabitsProvider>().deleteHabit(widget.habit);

      // Close both dialogs and return to home
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      Navigator.of(context).pop(); // Return to home screen
    }
  }
}
