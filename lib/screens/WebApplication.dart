import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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
  final authStorage = GetStorage('auth');

  String selectedUrl = '';
  String email = '';
  String password = '';


  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();

    // Enable virtual display.
    var vendorId = GetStorage().read("shop_id");

    var lastLoad = GetStorage().read("last_endpoint");
    var _email = authStorage.read("auth_email");
    var _password = authStorage.read("auth_password");

    if(_email == null && _password ==null){
      setState((){
        this.email = "";
        this.password = "";
      });
    }else{
      setState((){
        this.email = _email;
        this.password = _password;
      });
    }
    if(lastLoad == null){
      setState((){
        this.selectedUrl = "https://app.puppetvendors.com/shop/${vendorId}/login";
      });
    }else{
      setState((){
        this.selectedUrl = lastLoad;
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    print(selectedUrl);
    return SafeArea(
      left: false,
      top: true,
      right: false,
      bottom: false,
      child:selectedUrl == '' ? CircularProgressIndicator() : InAppWebView(
        initialUrlRequest: URLRequest(
            url: Uri.parse(selectedUrl)
        ),
          initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(

              ),
              ios: IOSInAppWebViewOptions(

              ),
              android: AndroidInAppWebViewOptions(
                  useHybridComposition: true
              )
          ),
          onWebViewCreated: (InAppWebViewController controller) {
            webView = controller;
            print(controller.webStorage.sessionStorage);
          },
          onLoadStart: (controller, url) {
            setState(() {
              this.selectedUrl = url?.toString() ?? '';
            });
          },
        onLoadStop: (controller, url) async {
          print("RETURN =>>>> ${url}");
          GetStorage().write("last_endpoint", url);

          print("RETURN DATA email=>${this.email} password=>$password");
          controller.webStorage.sessionStorage.getItems().then((value) => print("LOAD_STOP =>>>> ${value}"));
          const String functionBody = """
                var p = new Promise(function (resolve, reject) {
                 if(email){
                    window.document.getElementById("email").value = email;
                 }
                 if(password){
                    window.document.getElementById("password").value = password;
                 }
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
          var returnData = await controller.callAsyncJavaScript(functionBody: functionBody, arguments: {
            'email': email,
            'password': password
          });

          if(returnData?.value != null){
            var _email = returnData?.value["email"].toString();
            var _password = returnData?.value["password"].toString();
            print("RETURN PASS email => $_email password=>$_password");
            authStorage.write("auth_email", _email);
            authStorage.write("auth_password", _password.toString());
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
