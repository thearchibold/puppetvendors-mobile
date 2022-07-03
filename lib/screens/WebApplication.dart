import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:puppetvendors_mobile/services/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_storage/get_storage.dart';

class WebApplication extends StatefulWidget {
  const WebApplication({Key? key}) : super(key: key);

  @override
  State<WebApplication> createState() => _WebApplication();
}

class _WebApplication extends State<WebApplication> {
  InAppWebViewController? webView;

  String pageUrl = "";
  String email = '';
  String password = '';
  bool performLogin = false;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    initStorage();
  }

  void initStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? auth_email = prefs.getString('auth_email');
    final String? auth_pass = prefs.getString('auth_password');
    if(auth_email == "null" || auth_pass == "null" || auth_email == null || auth_pass == null){
      setState(() {
        pageUrl = "${AppConstants.APP_URL}/shop/${GetStorage().read("shop_id")}/login";
      });
    }else{
      setState(() {
        pageUrl = "${AppConstants.APP_URL}/shop/${GetStorage().read("shop_id")}/login?email=$auth_email&password=$auth_pass&action=autoLogin";
      });
    }

  }

  void writeToLocal(var email, var password) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString('auth_email', email.toString());
      await prefs.setString('auth_password', password.toString());
    } catch (e) {
      print("ERROR SAVING AUTH $e");
    }
  }

  void clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.remove('auth_email');
      await prefs.remove('auth_password');
    } catch (e) {
      print("ERROR REMOVING AUTH $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      left: false,
      top: true,
      right: false,
      bottom: false,
      child: pageUrl == ""
          ? Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(
                    color: Colors.black45,
                  ),
                ],
              ),
            )
          : InAppWebView(
              initialUrlRequest: URLRequest(url: Uri.parse(pageUrl)),
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(),
                  ios: IOSInAppWebViewOptions(),
                  android:
                      AndroidInAppWebViewOptions(useHybridComposition: true)),
              onWebViewCreated: (InAppWebViewController controller) {
                webView = controller;
              },
              onLoadStart: (controller, url) async {
                if (url.toString().contains("myshopify.com/password")) {
                  print("User is logging out-clear auth");
                  clearAuth();
                  webView?.loadUrl(urlRequest: URLRequest(url: Uri.parse("${AppConstants.APP_URL}/shop/${GetStorage().read("shop_id")}/login")));
                  // user has logged out, so clear the local username and password
                }
              },
              onLoadStop: (controller, url) async {
                if (url.toString().contains("portal/dashboard")) {
                  var notificationData = GetStorage().read("has_notif");
                  if (notificationData != null) {
                    Map<String, dynamic> data =
                        Map<String, dynamic>.from(jsonDecode(notificationData));
                    var orderId = data["order_id"].toString();
                    webView?.loadUrl(
                        urlRequest: URLRequest(
                            url: Uri.parse(
                                "${AppConstants.APP_URL}/portal/order/$orderId?vendorId=${GetStorage().read("vendor_id")}")));
                    GetStorage().remove("has_notif");
                  }
                }

                GetStorage().write("last_endpoint", url);
                const String functionBody = """
                var p = new Promise(function (resolve, reject) {
                 let loginBtn = window.document.getElementsByClassName("login-button");
                 if(loginBtn.length){
                    loginBtn[0].onclick = function(){
                      resolve({
                        email: window.document.getElementById("email").value,
                        password: window.document.getElementById("password").value
                      })
                    }
                 }
              });
              await p;
              return p;  
          """;
                var returnData = await controller.callAsyncJavaScript(
                    functionBody: functionBody, arguments: {});
                if (returnData?.value != null) {
                  var _email = returnData?.value["email"].toString();
                  var _password = returnData?.value["password"].toString();
                  writeToLocal(_email, _password);
                }
              }),
    );
  }
}

/*
*
* */
