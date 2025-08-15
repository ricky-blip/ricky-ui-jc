import 'package:flutter/material.dart';
import 'package:ricky_ui_jc/network/config_network_service.dart';
import 'package:ricky_ui_jc/screen/0.auth/login_screen.dart';
import 'package:ricky_ui_jc/screen/config/url_config_screen.dart';
import 'package:ricky_ui_jc/screen/main_screen.dart';
import 'package:ricky_ui_jc/screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ricky_ui_jc/network/network_api.dart'; // tempat baseUrlHp

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  showLocalNotification(
    message.notification?.title ?? 'Notifikasi',
    message.notification?.body ?? '',
  );
}

void showLocalNotification(String title, String body) {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'com.ricky.ricky_app.sales_order',
    'Sales Order',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'New sales order notification',
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // inisialisasi notifikasi lokal
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // request permission notif
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    showLocalNotification(
      message.notification?.title ?? 'Notifikasi',
      message.notification?.body ?? '',
    );
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final prefs = await SharedPreferences.getInstance();
  String? savedUrl = prefs.getString('baseUrlHp');

  if (savedUrl != null) {
    baseUrlHp = savedUrl;
  }

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Selo',
      theme: ThemeData(primarySwatch: Colors.red),
      // url bisa domain, jangan ip saja
      // home: savedUrl == null ? const UrlConfigScreen() : const SplashScreen(),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
      },
    ),
  );
}
