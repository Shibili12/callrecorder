import 'package:callrecorder/calllogpage.dart';
import 'package:callrecorder/callrecorder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CallRecorderScreen(),
    );
  }
}
