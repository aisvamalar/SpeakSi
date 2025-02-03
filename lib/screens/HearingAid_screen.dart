import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:convert';
import 'dart:async';

// Top-level notification handler
@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  if (receivedAction.actionType == ActionType.Default) {
    debugPrint('Notification action received: ${receivedAction.id}');
  }
}

// Notification initialization
Future<void> initializeNotifications() async {
  await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'hearing_aid_channel',
          channelName: 'Hearing Aid Notifications',
          channelDescription: 'Notifications for hearing aid maintenance',
          defaultColor: Colors.red,
          ledColor: Colors.red,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          enableVibration: true,
          enableLights: true,
          playSound: true,
        )
      ],
      debug: true
  );

  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await initializeNotifications();

  // Set up background action handler
  await AwesomeNotifications().setListeners(
    onActionReceivedMethod: onActionReceivedMethod,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hearing Aid Monitor',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      home: const HearingAidScreen(),
    );
  }
}

Future<void> showNotification() async {
  try {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'hearing_aid_channel',
        title: 'Hearing Aid Alert',
        body: 'Your hearing aid needs cleaning! The earwax level is in the danger zone.',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Alarm,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'MARK_DONE',
          label: 'Mark as Done',
        ),
      ],
    );
  } catch (e) {
    debugPrint('Error showing notification: $e');
    // Try to reinitialize channel and show notification again
    await initializeNotifications();
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'hearing_aid_channel',
          title: 'Hearing Aid Alert',
          body: 'Your hearing aid needs cleaning! The earwax level is in the danger zone.',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Alarm,
        ),
      );
    } catch (e) {
      debugPrint('Failed to show notification after reinitialization: $e');
    }
  }
}

class HearingAidScreen extends StatefulWidget {
  const HearingAidScreen({super.key});

  @override
  State<HearingAidScreen> createState() => _HearingAidScreenState();
}

class _HearingAidScreenState extends State<HearingAidScreen> {
  double _gaugeValue = 0.0;
  bool _hasNotifiedForRedZone = false;
  String _lastDataValue = "Loading...";
  Timer? _monitoringTimer;
  Timer? _dataFetchTimer;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _setupNotifications();
    _startDataFetching();
    _startMonitoring();
  }

  Future<void> _setupNotifications() async {
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  void _startDataFetching() {
    _fetchLastData();
    _dataFetchTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchLastData();
    });
  }

  void _startMonitoring() {
    _monitoringTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_gaugeValue >= 0.75) {
        if (!_hasNotifiedForRedZone) {
          _hasNotifiedForRedZone = true;
          showNotification();
          _callResetApi();
        }
      } else {
        _hasNotifiedForRedZone = false;
      }
    });
  }

  Future<void> _fetchLastData() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.232.49:5000/get_earwax_level'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          _isConnected = true;
          if (data['earwax_percentage'] != null) {
            var value = double.tryParse(data['earwax_percentage'].toString());
            if (value != null) {
              _gaugeValue = value / 100;
              _lastDataValue = "${value.toStringAsFixed(1)}%";
            } else {
              _lastDataValue = "Invalid data format";
            }
          } else {
            _lastDataValue = "No data available";
          }
        });
      } else {
        setState(() => _isConnected = false);
        _fetchFallbackData();
      }
    } catch (e) {
      setState(() => _isConnected = false);
      debugPrint('Error fetching data: $e');
      _fetchFallbackData();
    }
  }

  Future<void> _fetchFallbackData() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.232.49:5000/reset_earwax'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          if (data['value'] != null) {
            var value = double.tryParse(data['value'].toString());
            if (value != null) {
              _gaugeValue = value / 100;
              _lastDataValue = "Last Recorded: ${value.toStringAsFixed(1)}%";
            } else {
              _lastDataValue = "Invalid fallback data";
            }
          } else {
            _lastDataValue = "No fallback data";
          }
        });
      } else {
        setState(() {
          _lastDataValue = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _lastDataValue = "Connection error";
      });
    }
  }

  Future<void> _callResetApi() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.232.49:5000/reset_earwax'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        debugPrint('Reset API called successfully');
      } else {
        debugPrint('Reset API failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Reset API error: $e');
    }
  }

  Future<void> _refreshData() async {
    await _fetchLastData();
  }

  @override
  void dispose() {
    _monitoringTimer?.cancel();
    _dataFetchTimer?.cancel();
    super.dispose();
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.white)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _isConnected ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isConnected ? Icons.wifi : Icons.wifi_off,
            color: _isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            _isConnected ? 'Connected' : 'Disconnected',
            style: TextStyle(
              color: _isConnected ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Hearing Aid Monitor'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildStatusIndicator(),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: CustomPaint(
                    painter: GaugePainter(_gaugeValue),
                    size: const Size(double.infinity, 200),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Earwax Level: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _lastDataValue,
                        style: TextStyle(
                          fontSize: 16,
                          color: _gaugeValue >= 0.75 ? Colors.red : Colors.white,
                          fontWeight: _gaugeValue >= 0.75 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cleaning Guide:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTip('Power Off & Remove Battery: Turn off device and remove battery'),
                      _buildTip('Surface Cleaning: Use soft, dry cloth only - avoid water'),
                      _buildTip('Wax Removal: Use proper brush or wax pick for openings'),
                      _buildTip('Tubing Care: Clean and dry thoroughly if detachable'),
                      _buildTip('Moisture Removal: Use dehumidifier or drying kit'),
                      _buildTip('Inspection: Check for blockages and damage'),
                      _buildTip('Storage: Keep in dry, safe case when not in use'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double value;

  GaugePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 20);
    final radius = size.width * 0.4;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = math.pi;
    const sweepAngle = math.pi;
    const segments = 4;
    final segmentAngle = sweepAngle / segments;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30;

    final colors = [Colors.green, Colors.yellow, Colors.orange, Colors.red];
    for (var i = 0; i < segments; i++) {
      paint.color = colors[i];
      canvas.drawArc(
        rect,
        startAngle + (i * segmentAngle),
        segmentAngle,
        false,
        paint,
      );
    }

    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final angle = startAngle + sweepAngle * value;
    final needleLength = radius - 10;
    final endPoint = Offset(
      center.dx + needleLength * math.cos(angle),
      center.dy + needleLength * math.sin(angle),
    );

    canvas.drawLine(center, endPoint, needlePaint);

    final pivotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 8, pivotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}