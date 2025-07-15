import 'dart:async';
import 'dart:developer';
import 'package:firebasetodo/core/consts/currentuser.dart';
import 'package:firebasetodo/core/consts/globals.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// DEFINE ROUTER OBJECT INSIDE

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(requestAlertPermission: true),
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        _handleNotificationClick(details.payload);
      },
    );

    // Firebase permission
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    // Log token (optional)
    String? token = await _messaging.getToken();
    log("FCM Token: $token");
    // Foreground message
    FirebaseMessaging.onMessage.listen((message) {
      _showNotification(message);
    });
    // Background click
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationClick(message.data['route']);
    });
    // Terminated state
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage.data['route']);
    }
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'channel_id',
          'channel_name',
          channelDescription: 'your_channel_description',
          importance: Importance.max,
          priority: Priority.high,
          color: Colors.black,
        );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );
    await _localNotifications.show(
      0,
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      platformDetails,
      payload: message.data['route'],
    );
  }

  Future<void> displayNotification({title, body, route}) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'channel_id',
          'channel_name',
          channelDescription: 'your_channel_description',
          importance: Importance.max,
          priority: Priority.high,
          color: Colors.black,
        );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );
    await _localNotifications.show(
      0,
      title,
      body,
      platformDetails,
      payload: route,
    );
  }

  void _handleNotificationClick(String? route) {
    if (route != null && route.isNotEmpty) {
      if (Currentuser.isLogin) {
        router.go(route);
      }
    }
  }
}
