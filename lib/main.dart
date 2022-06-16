
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:puppetvendors_mobile/screens/AuthApp.dart';
import 'package:puppetvendors_mobile/screens/SplashScreen.dart';
import 'package:puppetvendors_mobile/screens/WebApplication.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:io';




Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('handling message $message');
}


Future<void> _firebaseMessagingNotificationClicked(RemoteMessage message) async {
  print('handling message firebae notif click $message');

}

void requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings =  await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: false,
    criticalAlert: true,
    sound: true,
    provisional: false
  );

  if(settings.authorizationStatus == AuthorizationStatus.authorized){
    print('user permission granted');
  }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
    print('provisional permission granted');
  }else{
    print('user permission NOT granted');
  }
}


void getFirebaseToken()  {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  var vendorId = GetStorage().read('vendor_id');
  messaging.getToken().then((value) => {
    if(vendorId != null){
      saveVendorToken(vendorId, value)
    }
  });
}

void listenNotifications() async {
  late AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'puppet_vendor_notif_channel_one',
      'Puppet Vendor Notification',
      importance: Importance.high);

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = notification?.android;
    AppleNotification? apple = notification?.apple;

    if(notification!= null  && android != null){
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            icon: 'launch_background'
          )
        )
      );
    }
  });
}


Future<void> main() async{
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  requestPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessageOpenedApp.listen(_firebaseMessagingNotificationClicked);

  listenNotifications();

  FirebaseMessaging.instance.onTokenRefresh.listen((event) {
    getFirebaseToken();
  });

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  //FirebaseMessaging.onMessageOpenedApp();

  runApp(
    Navigation()
  );
}

class Navigation extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/auth': (context) =>  const AuthApp(),
        '/app': (context) => const WebApplication()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

