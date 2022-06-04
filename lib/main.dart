import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:puppetvendors_mobile/firebase_options.dart';
import 'package:puppetvendors_mobile/screens/AuthApp.dart';
import 'package:puppetvendors_mobile/screens/SplashScreen.dart';
import 'package:puppetvendors_mobile/screens/WebApplication.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';



Future<void> _firebaseMessaginBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('handling message $message');
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


void getFirebaseToken() {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  messaging.getToken().then((value) => print(value));
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

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  requestPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessaginBackgroundHandler);
  getFirebaseToken();
  listenNotifications();

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
      }
    );
  }
}

