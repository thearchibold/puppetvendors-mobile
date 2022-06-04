import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class SplashScreen extends StatefulWidget{
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {checkLoggedIn();});
  }

  void checkLoggedIn() async {
    print("started");
    var prefs = await SharedPreferences.getInstance();
    print("splash prefs response ${prefs.get("data")}");

    var storedData = prefs.getString("data");
    if(storedData == null){
      Navigator.pushNamed(context, "/auth");
    }
    Map<String, dynamic> userData = jsonDecode(storedData!);
    Map<String, dynamic> vendor = userData['vendor'];
    Map<String, dynamic> shop = userData["shop"];

    var vendorId = vendor['_id'];
    print("vendor id ${shop['shopName']} $vendorId $splash_background ");

    var profileBanner = vendor["profile"]["profileBanner"];
    setState((){
      splash_background = profileBanner;
      _shop = shop != null ? shop['shopName'] : '';
      _vendor = vendor != null ? vendor['vendorName'] : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
             child: Column(
          children: [
          Image.network(splash_background, height: 100, width: 100,fit: BoxFit.cover,),
            Text(_shop != null ? _shop : '')
        ],
      ),
      )
      )
    );
  }
}