import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
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
    print("auth_email $auth_email");
    setState(() {
      pageUrl = auth_email != "null"
          ? "https://app.puppetvendors.com/shop/${GetStorage().read("shop_id")}/login?email=$auth_email&password=$auth_pass&action=autoLogin"
          : "https://app.puppetvendors.com/shop/${GetStorage().read("shop_id")}/login";
    });
  }

  void writeToLocal(var email, var password) async {
    print("SAVING CREDENTIALS");
    final prefs = await SharedPreferences.getInstance();

    try {
      GetStorage().write("auth_email", email.toString());
      GetStorage().write("auth_password", password.toString());
      await prefs.setString('auth_email', email.toString());
      await prefs.setString('auth_password', password.toString());
    } catch (e) {
      print("ERROR SAVING AUTH $e");
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
                //print(controller.webStorage.sessionStorage);
              },
              onLoadStart: (controller, url) {
                setState(() {
                  //pageUrl = url?.toString() ?? '';
                });
              },
              onLoadStop: (controller, url) async {
                print("CURRENT URL ==>>> $url");

                if (url.toString().contains("portal/dashboard")) {
                  var notificationData = GetStorage().read("has_notif");
                  if (notificationData != null) {
                    Map<String, dynamic> data =
                        Map<String, dynamic>.from(jsonDecode(notificationData));
                    var orderId = data["order_id"].toString();
                    print("PASSED DATA ==> Has some data $orderId");
                    webView?.loadUrl(
                        urlRequest: URLRequest(
                            url: Uri.parse(
                                "https://app.puppetvendors.com/portal/order/$orderId?vendorId=${GetStorage().read("vendor_id")}")));
                    GetStorage().remove("has_notif");
                  }
                }

                final prefs = await SharedPreferences.getInstance();
                final String? auth_email = prefs.getString('auth_email');
                final String? auth_pass = prefs.getString('auth_password');
                print("AUTH_EMAIL PREF =>>>> ${auth_email} - $auth_pass");
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
                  print("RETURN PASS email => $_email password=>$_password");
                  writeToLocal(_email, _password);
                }
              },
              //url: selectedUrl,
              //javascriptMode: JavascriptMode.unrestricted,

              //withZoom: false,
              //withLocalStorage: true,
              //clearCookies: false,
              //clearCache: false,
            ),
    );
  }
}

/*
*
* */
