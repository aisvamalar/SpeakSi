import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class BatteryScreen extends StatefulWidget {
  @override
  _BatteryScreenState createState() => _BatteryScreenState();
}

class _BatteryScreenState extends State<BatteryScreen> {
  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize awesome notifications
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await AwesomeNotifications().initialize(
      null, // No default icon, use channel icon
      [
        NotificationChannel(
          channelKey: 'battery_care_channel',
          channelName: 'Battery Care Notifications',
          channelDescription: 'Notifications for battery change reminders',
          defaultColor: Colors.purple,
          ledColor: Colors.purple,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        )
      ],
      debug: true,
    );

    // Request notification permissions
    await _requestPermissions();
  }

  Future<bool> _requestPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    return isAllowed;
  }

  Future<void> _scheduleBatteryReminder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if selected time is in the future
      if (_selectedDateTime.isBefore(DateTime.now())) {
        _showErrorSnackbar('Please select a future date and time');
        return;
      }

      // Generate a unique ID for the notification
      final notificationId = _selectedDateTime.millisecondsSinceEpoch ~/ 1000;

      // Schedule the notification
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'battery_care_channel',
          title: 'Battery Change Reminder',
          body: 'It is time to change your hearing aid battery',
          wakeUpScreen: true,
          category: NotificationCategory.Reminder,
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar.fromDate(date: _selectedDateTime),
      );

      // Show success message
      _showSuccessSnackbar(
        'Reminder scheduled for ${_formatDateTime(_selectedDateTime)}',
      );
    } catch (e) {
      _showErrorSnackbar('Failed to schedule notification: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        'at ${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1B24), // Puplish black
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ).animate().fadeIn(delay: 200.ms),
                  SizedBox(width: 16),
                  Text(
                    'Battery Care Reminder',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
                ],
              ),

              SizedBox(height: 32),

              // Date and Time Selection
              GestureDetector(
                onTap: _selectDateTime,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF2D2835), // Slightly darker Puplish black
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Set Reminder',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),
                      Text(
                        _formatDateTime(_selectedDateTime),
                        style: GoogleFonts.poppins(
                          color: Color(0xFFA86BFF), // Puplish purple
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.2),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              ),

              SizedBox(height: 32),

              // Set Reminder Button
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _scheduleBatteryReminder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFA86BFF), // Puplish purple
                    minimumSize: Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    'Set Battery Reminder',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms).scale(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(),
            dialogBackgroundColor: Color(0xFF2D2835), // Slightly darker Puplish black
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(),
              dialogBackgroundColor: Color(0xFF2D2835), // Slightly darker Puplish black
            ),
            child: child!,
          );
        },
      );

      if (selectedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }
}