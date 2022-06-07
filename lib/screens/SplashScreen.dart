import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import '../services/api_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  var splash_background;
  var _shop = '';
  var _vendor = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkLoggedIn();
    });
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


  void checkLoggedIn() {
    var storedData = GetStorage().read("data");
    if (storedData == null) {
      Navigator.pushNamed(context, "/auth");
      return;
    }else{

      Map<String, dynamic> userData = jsonDecode(storedData!);
      Map<String, dynamic> vendor = userData['vendor'];
      Map<String, dynamic> shop = userData["shop"];

      var vendorId = vendor['_id'];
      GetStorage().write("vendor_id", vendorId);
      GetStorage().write("shop_id", vendor['shopId']);

      var profileBanner = vendor["profile"]["profileBanner"];
      setState(() {
        splash_background = profileBanner;
        _shop = shop != null ? shop['shopName'] : '';
        _vendor = vendor != null ? vendor['vendorName'] : '';
      });

      getFirebaseToken();

      Timer(const Duration(seconds: 5), ()=>{
        Navigator.pushNamed(context, '/app')
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  if (splash_background != null)
                    Image.network(
                      splash_background,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  Text(_shop != null ? _shop : '')
                ],
              ),
            )));
  }
}
