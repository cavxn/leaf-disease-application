import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:convert';
import 'dart:async';
import '../utils/app_theme.dart';

class WaterReminderScreen extends StatefulWidget {
  const WaterReminderScreen({super.key});

  @override
  State<WaterReminderScreen> createState() => _WaterReminderScreenState();
}

class _WaterReminderScreenState extends State<WaterReminderScreen> {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  List<WaterReminder> _reminders = [];
  bool _isLoading = false;
  int _nextId = 1;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _clearAllNotifications(); // Clear any existing notifications with invalid IDs
    _loadReminders();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    
    // Request notification permissions
    await _requestNotificationPermissions();
    
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    
    // Create notification channel for Android
    await _createNotificationChannel();
  }

  Future<void> _requestNotificationPermissions() async {
    // Request permissions for Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'water_reminders',
      'Water Reminders',
      description: 'Reminders for watering your plants',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _clearAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getStringList('water_reminders') ?? [];
      
      // Filter out any reminders with invalid IDs (too large for 32-bit)
      final validReminders = <WaterReminder>[];
      for (final json in remindersJson) {
        try {
          final reminder = WaterReminder.fromJson(jsonDecode(json));
          if (reminder.id <= 2147483647) { // Check if ID is within 32-bit limit
            validReminders.add(reminder);
          }
        } catch (e) {
          print('Error parsing reminder: $e');
        }
      }
      
      _reminders = validReminders;
      
      // Set the next ID to be higher than the highest existing ID
      if (_reminders.isNotEmpty) {
        _nextId = _reminders.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1;
      }
      
      // Save the cleaned reminders back to storage
      await _saveReminders();
    } catch (e) {
      print('Error loading reminders: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = _reminders.map((reminder) => jsonEncode(reminder.toJson())).toList();
    await prefs.setStringList('water_reminders', remindersJson);
  }

  Future<void> _addReminder(WaterReminder reminder) async {
    setState(() {
      _reminders.add(reminder);
    });
    await _saveReminders();
    await _scheduleNotification(reminder);
  }

  Future<void> _deleteReminder(int index) async {
    final reminder = _reminders[index];
    await _notifications.cancel(reminder.id);
    setState(() {
      _reminders.removeAt(index);
    });
    await _saveReminders();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder for ${reminder.plantName} deleted'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () async {
              setState(() {
                _reminders.insert(index, reminder);
              });
              await _saveReminders();
              await _scheduleNotification(reminder);
            },
          ),
        ),
      );
    }
  }

  Future<void> _scheduleNotification(WaterReminder reminder) async {
    final now = DateTime.now();
    final scheduledTime = DateTime(now.year, now.month, now.day, reminder.hour, reminder.minute);
    
    // If the time has passed today, schedule for tomorrow
    final notificationTime = scheduledTime.isBefore(now) 
        ? scheduledTime.add(const Duration(days: 1))
        : scheduledTime;

    await _notifications.zonedSchedule(
      reminder.id,
      '🌱 Water Reminder',
      'Time to water your ${reminder.plantName}!',
      _convertToTZDateTime(notificationTime),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'water_reminders',
          'Water Reminders',
          channelDescription: 'Reminders for watering your plants',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
          sound: const RawResourceAndroidNotificationSound('notification'),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'notification.wav',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  Future<void> _testNotification() async {
    await _notifications.show(
      999, // Test ID
      '🌱 Test Notification',
      'Water reminder notifications are working!',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'water_reminders',
          'Water Reminders',
          channelDescription: 'Reminders for watering your plants',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  void _showAddReminderDialog() {
    final TextEditingController plantController = TextEditingController();
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
    int frequency = 1; // days
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Water Reminder',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Keep your plants healthy',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          content: Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: plantController,
                    decoration: InputDecoration(
                      labelText: 'Plant Name',
                      hintText: 'e.g., My Monstera',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.eco_rounded, color: Color(0xFF3B82F6)),
                      ),
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.access_time_rounded, color: Color(0xFF3B82F6)),
                    ),
                    title: const Text('Reminder Time'),
                    subtitle: Text(
                      selectedTime.format(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setDialogState(() => selectedTime = time);
                      }
                    },
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.repeat_rounded, color: Color(0xFF3B82F6)),
                        ),
                        const SizedBox(width: 12),
                        const Text('Every'),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF3B82F6).withOpacity(0.3),
                              ),
                            ),
                            child: DropdownButton<int>(
                              value: frequency,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: [1, 2, 3, 7].map((days) => DropdownMenuItem(
                                value: days,
                                child: Text('$days day${days > 1 ? 's' : ''}'),
                              )).toList(),
                              onChanged: (value) => setDialogState(() => frequency = value!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (plantController.text.isNotEmpty) {
                  final reminder = WaterReminder(
                    id: _nextId++,
                    plantName: plantController.text,
                    hour: selectedTime.hour,
                    minute: selectedTime.minute,
                    frequency: frequency,
                    isActive: true,
                  );
                          await _addReminder(reminder);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text('Add Reminder'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.cyberGradient.colors.first : AppTheme.neonGradient.colors.first,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [const Color(0xFF3B82F6), const Color(0xFF3B82F6).withOpacity(0.7)],
                      ),
                    ),
                    child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Water Reminders',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Keep your plants hydrated',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _reminders.isEmpty
                        ? _buildEmptyState(theme, isDark)
                        : _buildRemindersList(theme, isDark),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _testNotification,
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            heroTag: "test",
            child: const Icon(Icons.notifications_rounded),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            onPressed: _showAddReminderDialog,
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Reminder'),
            heroTag: "add",
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
          borderRadius: BorderRadius.circular(24),
          border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [const Color(0xFF3B82F6).withOpacity(0.2), const Color(0xFF3B82F6).withOpacity(0.1)],
                ),
              ),
              child: const Icon(
                Icons.water_drop_outlined,
                size: 48,
                color: Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Water Reminders',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first water reminder to keep your plants healthy and hydrated.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddReminderDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add First Reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersList(ThemeData theme, bool isDark) {
    return ListView.builder(
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final reminder = _reminders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 20),
            ),
            title: Text(
              reminder.plantName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${TimeOfDay(hour: reminder.hour, minute: reminder.minute).format(context)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF3B82F6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Every ${reminder.frequency} day${reminder.frequency > 1 ? 's' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: reminder.isActive,
                  onChanged: (value) async {
                    setState(() => reminder.isActive = value);
                    await _saveReminders();
                    if (value) {
                      await _scheduleNotification(reminder);
                    } else {
                      await _notifications.cancel(reminder.id);
                    }
                  },
                  activeColor: const Color(0xFF3B82F6),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => _deleteReminder(index),
                    icon: const Icon(Icons.delete_rounded),
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WaterReminder {
  final int id;
  final String plantName;
  final int hour;
  final int minute;
  final int frequency;
  bool isActive;

  WaterReminder({
    required this.id,
    required this.plantName,
    required this.hour,
    required this.minute,
    required this.frequency,
    required this.isActive,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'plantName': plantName,
    'hour': hour,
    'minute': minute,
    'frequency': frequency,
    'isActive': isActive,
  };

  factory WaterReminder.fromJson(Map<String, dynamic> json) => WaterReminder(
    id: json['id'],
    plantName: json['plantName'],
    hour: json['hour'],
    minute: json['minute'],
    frequency: json['frequency'],
    isActive: json['isActive'],
  );
}
