import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';

class CallRecorderScreen extends StatefulWidget {
  const CallRecorderScreen({Key? key}) : super(key: key);

  @override
  _CallRecorderScreenState createState() => _CallRecorderScreenState();
}

class _CallRecorderScreenState extends State<CallRecorderScreen> {
  FlutterSoundRecorder? recorder;
  FlutterSoundPlayer? player;
  String? filePath;
  bool isRecording = false;
  List<String> recordedFiles = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    recorder = FlutterSoundRecorder();
    player = FlutterSoundPlayer();
    getRecordedCalls();
    init();
  }

  init() async {
    await _showNotification();
  }

  Future<void> _showNotification() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      // iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'my_notification_channel',
      'My Notification Channel',
      importance: Importance.max,
      priority: Priority.high,
    );
    // var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      // iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'call recorder',
      'record your call....',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  @override
  void dispose() {
    recorder?.openRecorder();
    player?.closePlayer();
    super.dispose();
  }

  Future<void> getRecordedCalls() async {
    Directory dir = await getApplicationDocumentsDirectory();
    recordedFiles = dir
        .listSync(recursive: true)
        .where((file) => file.path.endsWith('.aac'))
        .map((file) => file.path)
        .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: Icon(
          Icons.phone_in_talk,
          color: Colors.yellowAccent,
        ),
        backgroundColor: Colors.black,
        title: Text("Record Call"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 200,
              width: 200,
              child: IconButton(
                onPressed: () {
                  isRecording ? stopRecording() : startRecording();
                },
                icon: Icon(
                  isRecording ? Icons.stop_circle : Icons.play_circle_outline,
                  size: 100,
                  color: Colors.yellowAccent,
                ),
              ),
            ),
            Text(
              isRecording ? "Recording..." : "Tap to Record",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recorded Calls:",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: ListView.builder(
                  itemCount: recordedFiles.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.white,
                      child: ListTile(
                        title: Text("Call ${recordedFiles.length - index}"),
                        onTap: () {
                          playRecording(recordedFiles[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      try {
        await recorder?.openRecorder();
        filePath = (await getApplicationDocumentsDirectory()).path +
            "/${DateTime.now().millisecondsSinceEpoch}.aac";
        await recorder?.startRecorder(toFile: filePath);
        setState(() {
          isRecording = true;
        });
      } catch (e) {
        print('Error starting recorder: $e');
      }
    } else {
      // Handle microphone permission denied
    }
  }

  Future<void> stopRecording() async {
    try {
      await recorder?.stopRecorder();
      await recorder?.closeRecorder();
      setState(() {
        isRecording = false;
      });
      getRecordedCalls();
    } catch (e) {
      print('Error stopping recorder: $e');
    }
  }

  Future<void> playRecording(String path) async {
    try {
      await player?.openPlayer();
      await player?.startPlayer(fromURI: path);
    } catch (e) {
      print('Error playing recording: $e');
    }
  }
}
