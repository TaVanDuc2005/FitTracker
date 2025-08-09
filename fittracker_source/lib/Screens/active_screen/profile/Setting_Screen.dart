import 'package:flutter/material.dart';
import 'package:fittracker_source/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fittracker_source/Screens/initial_screen/Welcome_Screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _waterNotification = false;
  bool _mealNotification = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Notification Preferences",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // 💧 Water Reminder
          SwitchListTile(
            title: const Text('Water Log Reminder'),
            value: _waterNotification,
            onChanged: (value) {
              setState(() => _waterNotification = value);
              if (value) {
                final times = [
                  [8, 0],
                  [10, 0],
                  [12, 0],
                  [14, 0],
                  [16, 0],
                  [18, 0],
                  [20, 0],
                  [22, 0],
                ];
                for (int i = 0; i < times.length; i++) {
                  NotificationService.scheduleDailyNotification(
                    id: 201 + i,
                    title: 'Time to drink water',
                    body: 'Stay hydrated! Log your water intake.',
                    hour: times[i][0],
                    minute: times[i][1],
                  );
                }
              } else {
                for (int i = 0; i < 8; i++) {
                  NotificationService.cancel(201 + i);
                }
              }
            },
          ),

          const Divider(),

          // 🍽️ Meal Reminder
          SwitchListTile(
            title: const Text('Meal Log Reminder'),
            value: _mealNotification,
            onChanged: (value) {
              setState(() => _mealNotification = value);
              if (value) {
                NotificationService.scheduleDailyNotification(
                  id: 101,
                  title: 'Log your breakfast',
                  body: 'Have you recorded your breakfast today?',
                  hour: 8,
                  minute: 0,
                );
                NotificationService.scheduleDailyNotification(
                  id: 102,
                  title: 'Log your lunch',
                  body: 'Don’t forget to log your lunch.',
                  hour: 12,
                  minute: 0,
                );
                NotificationService.scheduleDailyNotification(
                  id: 103,
                  title: 'Log your dinner',
                  body: 'Remember to log your dinner before the day ends.',
                  hour: 18,
                  minute: 0,
                );
              } else {
                NotificationService.cancel(101);
                NotificationService.cancel(102);
                NotificationService.cancel(103);
              }
            },
          ),

          const SizedBox(height: 24),

          // 🔐 Log Out Button
          ElevatedButton.icon(
            onPressed: logOut,
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> logOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }
}
