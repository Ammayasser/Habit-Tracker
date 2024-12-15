import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/habits_provider.dart';
import '../widgets/add_habit_dialog.dart';
import 'habit_details_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.withOpacity(0.1),
                    const Color(0xFF1A1A1A),
                  ],
                ),
              ),
            ),
            // Content
            CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  backgroundColor: Colors.transparent,
                  expandedHeight: 120,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'My Habits',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(duration: 600.ms),
                    centerTitle: false,
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  ),
                ),
                // Habits Grid
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: Consumer<HabitsProvider>(
                    builder: (context, habitsProvider, child) {
                      final habits = habitsProvider.habits;
                      if (habits.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_task_rounded,
                                  size: 80,
                                  color: Colors.blue.withOpacity(0.5),
                                )
                                    .animate(
                                        onPlay: (controller) =>
                                            controller.repeat())
                                    .scale(
                                      duration: 2.seconds,
                                      begin: const Offset(1, 1),
                                      end: const Offset(1.1, 1.1),
                                    )
                                    .then()
                                    .scale(
                                      duration: 2.seconds,
                                      begin: const Offset(1.1, 1.1),
                                      end: const Offset(1, 1),
                                    ),
                                const SizedBox(height: 16),
                                Text(
                                  'No habits yet',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ).animate().fadeIn(duration: 600.ms),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap + to add your first habit',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                )
                                    .animate()
                                    .fadeIn(duration: 600.ms, delay: 200.ms),
                              ],
                            ),
                          ),
                        );
                      }

                      return SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.95,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final habit = habits[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HabitDetailsScreen(habit: habit),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                color: const Color(0xFF2A2A2A),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        habit.color.withOpacity(0.2),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Icon and Streak Row
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: habit.color
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                habit.icon,
                                                color: habit.color,
                                                size: 24,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black26,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.local_fire_department,
                                                    color: habit.color,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${habit.completionHistory.values.where((v) => v).length}',
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white70,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Habit Name
                                        Text(
                                          habit.title,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (habit.hasReminder &&
                                            habit.reminderTime != null)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  color: habit.color
                                                      .withOpacity(0.7),
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  habit.reminderTime!
                                                      .format(context),
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        // Progress Bar
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  '${(habit.completionRate * 100).toStringAsFixed(0)}%',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '${habit.completionHistory.values.where((v) => v).length}/${habit.completionHistory.length}',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: LinearProgressIndicator(
                                                value: habit.completionRate,
                                                backgroundColor: Colors.black26,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(habit.color),
                                                minHeight: 6,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        // Week Progress
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: List.generate(7, (index) {
                                            final date = DateTime.now()
                                                .subtract(Duration(
                                                    days:
                                                        DateTime.now().weekday -
                                                            1 -
                                                            index));
                                            final isCompleted =
                                                habit.isDateCompleted(date);
                                            final isToday = date.year ==
                                                    DateTime.now().year &&
                                                date.month ==
                                                    DateTime.now().month &&
                                                date.day == DateTime.now().day;

                                            return GestureDetector(
                                              onTap: () {
                                                habit.toggleCompletion(date);
                                                context
                                                    .read<HabitsProvider>()
                                                    .updateHabit(habit);
                                              },
                                              child: Column(
                                                children: [
                                                  Text(
                                                    [
                                                      'M',
                                                      'T',
                                                      'W',
                                                      'T',
                                                      'F',
                                                      'S',
                                                      'S'
                                                    ][index],
                                                    style: TextStyle(
                                                      color: Colors.grey[400],
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    width: 20,
                                                    height: 20,
                                                    decoration: BoxDecoration(
                                                      color: isCompleted
                                                          ? habit.color
                                                          : Colors.grey[800],
                                                      shape: BoxShape.circle,
                                                      border: isToday
                                                          ? Border.all(
                                                              color:
                                                                  Colors.white,
                                                              width: 1.5,
                                                            )
                                                          : null,
                                                    ),
                                                    child: isCompleted
                                                        ? const Icon(
                                                            Icons.check,
                                                            size: 12,
                                                            color: Colors.white,
                                                          )
                                                        : null,
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: habits.length,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // FAB with animation
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF448AFF)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => showDialog(
              context: context,
              builder: (context) => const AddHabitDialog(),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      )
          .animate(onPlay: (controller) => controller.repeat())
          .scaleXY(
            begin: 1,
            end: 1.05,
            duration: 2.seconds,
            curve: Curves.easeInOut,
          )
          .then()
          .scaleXY(
            begin: 1.05,
            end: 1,
            duration: 2.seconds,
            curve: Curves.easeInOut,
          ),
    );
  }
}
