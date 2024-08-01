// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_home_app/components/theme_provider.dart';
import 'package:smart_home_app/main.dart';
import 'package:provider/provider.dart';

class MotionDetectionPage extends StatefulWidget {
  const MotionDetectionPage({super.key});

  @override
  MotionDetectionPageState createState() => MotionDetectionPageState();
}

class MotionDetectionPageState extends State<MotionDetectionPage> {
  int _motionEventsCount = 0;
  bool _motionDetected = false;
  bool _notificationShown = false;
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  final List<FlSpot> _accelerometerData = [];
  double _previousZ = 0.0;
  int _dataIndex = 0;
  Timer? _motionTimer;

  @override
  void initState() {
    super.initState();
    _startListeningToAccelerometer();
  }

  @override
  void dispose() {
    _accelerometerSubscription.cancel();
    _motionTimer?.cancel();
    super.dispose();
  }

  void _startListeningToAccelerometer() {
    _accelerometerSubscription = SensorsPlatform.instance.accelerometerEventStream().listen((event) {
      setState(() {
        if ((event.z - _previousZ).abs() > 10.0) {
          _previousZ = event.z;
          _motionEventsCount++;
          _motionDetected = true;
          _triggerNotification();
          _addZigzagData();

          // Cancel any existing timer and start a new one
          _motionTimer?.cancel();
          _motionTimer = Timer(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _motionDetected = false;
                _notificationShown = false;
              });
            }
          });
        } else {
          _addFlatLineData();
        }
      });
    });
  }

  void _addZigzagData() {
    for (int i = 0; i < 5; i++) {
      _accelerometerData.add(FlSpot(_dataIndex.toDouble(), i.isEven ? 10 : -10));
      _dataIndex++;
      if (_accelerometerData.length > 20) {
        _accelerometerData.removeAt(0);
      }
    }
  }

  void _addFlatLineData() {
    _accelerometerData.add(FlSpot(_dataIndex.toDouble(), 0));
    _dataIndex++;
    if (_accelerometerData.length > 20) {
      _accelerometerData.removeAt(0);
    }
  }

  void _triggerNotification() async {
    if (!_notificationShown) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'MotionDetection_channel',
        'Motion Detection Alerts',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
        'Motion Detected!',
        'Your phone detected Shaking motion!',
        platformChannelSpecifics,
      );
      _notificationShown = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      theme: themeProvider.currentTheme,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.pinkAccent,
          title: const Text(
            'Motion Detection\nand Security',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
              fontSize: 22,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: themeProvider.isDarkMode
                    ? [Colors.grey[900]!, Colors.black]
                    : [Colors.pinkAccent, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
                color: Colors.white,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: themeProvider.isDarkMode
                ? null
                : DecorationImage(
                    image: AssetImage('lib/assets/11.jpg'),
                    fit: BoxFit.cover,
                  ),
            color: themeProvider.isDarkMode ? Colors.black : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Shake your Phone to detect Motion',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(181, 229, 13, 157)),
                ),
                const SizedBox(height: 20),
                Text(
                  'Motion Events Detected: $_motionEventsCount',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                const SizedBox(height: 20),
                Icon(
                  _motionDetected ? Icons.vibration : Icons.phone_android,
                  size: 100,
                  color: _motionDetected ? Colors.green : Colors.red,
                ),
                Text(
                  _motionDetected ? 'Motion Detected' : 'No Motion Detected',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _motionDetected ? Colors.green : Colors.red,
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: _accelerometerData,
                          isCurved: false,
                          color: Colors.yellow,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      gridData: FlGridData(show: true),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            theme: themeProvider.currentTheme,
            home: MotionDetectionPage(),
          );
        },
      ),
    ),
  );
}
