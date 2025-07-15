# 🔔 Firebase Push Notification Integration in Flutter

This guide walks through the complete setup for enabling push notifications in a Flutter application using `firebase_messaging` and `flutter_local_notifications`.

---

## 📋 Prerequisites

- Flutter SDK
- A Flutter app setup
- Firebase account

---

## 🚀 Step-by-Step Setup

### ✅ Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project.
3. Add your Flutter app to the project.
4. Download and place the `google-services.json` and `GoogleService-Info.plist` into their respective platform folders.

---

### ✅ Step 2: Connect Firebase to Your Flutter App

Follow the standard Firebase-Flutter setup:

- Use `firebase_core` and initialize it in `main.dart`.
- Ensure platform-specific Firebase configuration is complete.

---

### ✅ Step 3: Add Flutter Dependencies

In your `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.x.x
  firebase_messaging: ^15.2.9
  flutter_local_notifications: ^17.0.0
```

Then run:

```bash
flutter pub get
```

---

### ✅ Step 4: Create `notification_service.dart`

Path: `lib/core/services/notification_service.dart`

```dart
import 'dart:async';
import 'dart:developer';
import 'package:firebasetodo/core/consts/currentuser.dart';
import 'package:firebasetodo/core/consts/globals.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    String? token = await _messaging.getToken();
    log("FCM Token: $token");

    FirebaseMessaging.onMessage.listen((message) {
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationClick(message.data['route']);
    });

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
```

---

### ✅ Step 5: Update `main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init(); // Initialize notification service
  runApp(TodoApp());
}
```

---

### ✅ Step 6: Create Notification Icon

1. Go to: [Android Asset Studio – Notification Icons](https://romannurik.github.io/AndroidAssetStudio/icons-notification.html)
2. Upload your icon (transparent background).
3. Name the file: `ic_launcher`
4. Place it inside: `android/app/src/main/res/drawable/`

---

### ✅ Step 7: Add Color to `colors.xml`

Create `colors.xml` at:

```
android/app/src/main/res/values/colors.xml
```

```xml
<resources>
    <color name="notification_color">#000000</color>
</resources>
```

---

### ✅ Step 8: Update `AndroidManifest.xml`

File: `android/app/src/main/AndroidManifest.xml`

Add the following inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

Inside `<application>` tag:

```xml
      <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="channel_id"/>
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@drawable/ic_launcher" />
        <meta-data
        android:name="com.google.firebase.messaging.default_notification_color"
        android:resource="@color/notification_color" />



        <service
            android:name="com.google.firebase.messaging.FirebaseMessagingService"
            android:exported="true"
            tools:replace="android:exported">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT"/>
            </intent-filter>
        </service>

        <receiver
            android:name="com.google.firebase.iid.FirebaseInstanceIdReceiver"
            android:exported="true"
            android:enabled="true">
            <intent-filter>
                <action android:name="com.google.android.c2dm.intent.RECEIVE"/>
                <category android:name="${applicationId}"/>
            </intent-filter>
        </receiver>
```

---

## 📦 Additional Tips

- You can customize notification appearance using `AndroidNotificationDetails`.
- Use `message.data['route']` to navigate the user based on notification payload.

---

## ✅ Done!

You now have a fully functional push notification system in your Flutter app using Firebase and local notifications.
