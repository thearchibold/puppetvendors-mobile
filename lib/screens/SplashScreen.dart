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
    var vendorId = GetStorage().read("vendor_id");
    if (vendorId == null) {
      Navigator.pushNamed(context, "/auth");
      return;
    }else{

      var shopId = GetStorage().read("shop_id");

      var vendorId = GetStorage().read("vendor_id");
      var vendorName = GetStorage().read("vendor_name");
      var profileBanner = GetStorage().read("profile_banner");
      setState(() {
        splash_background = profileBanner;
        _shop = shopId ?? '';
        _vendor = vendorName ?? '';
      });

      getFirebaseToken();

      Timer(const Duration(seconds: 2), ()=>{
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
                  Text(_vendor != null ? _vendor : '')
                ],
              ),
            )));
  }
}
