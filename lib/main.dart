
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:puppetvendors_mobile/screens/AuthApp.dart';
import 'package:puppetvendors_mobile/screens/WebApplication.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:io';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();



Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('handling message $message');
}


Future<void> _firebaseMessagingNotificationClicked(RemoteMessage message) async {
  print('handling message firebae notif click ${message.notification} ${message.data}');
  GetStorage().write("has_notif", jsonEncode(message.data));
  navigatorKey.currentState?.pushNamed("/app");
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
    print("New push message is in");
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = notification?.android;
    AppleNotification? apple = notification?.apple;

    if(notification!= null){
      if(Platform.isAndroid && android != null){
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
      if(Platform.isIOS && apple != null){
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            const NotificationDetails(
                iOS: IOSNotificationDetails(

                )
            )
        );
      }
    }
  });
}


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  await Firebase.initializeApp();

  FirebaseMessaging.instance.getInitialMessage();

  requestPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessageOpenedApp.listen(_firebaseMessagingNotificationClicked);

  listenNotifications();



  runApp(
      Navigation()
  );


}

class Navigation extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      initialRoute:GetStorage().read('vendor_id') == null ? '/auth' : '/app',
      routes: {
        '/app': (context) => const WebApplication(),
        '/auth': (context) =>  const AuthApp()
      },
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
    );
  }
}

