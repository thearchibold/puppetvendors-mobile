import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:get_storage/get_storage.dart';



class WebApplication extends StatefulWidget {
  const WebApplication({Key? key}) : super(key: key);

  @override
  State<WebApplication> createState() => _WebApplication();
}

class _WebApplication extends State<WebApplication> {

  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }


  @override
  Widget build(BuildContext context) {
    var vendorId = GetStorage().read("shop_id");
    String selectedUrl = "https://app.puppetvendors.com/shop/$vendorId/login";
    print(selectedUrl);
    return SafeArea(
      left: false,
      top: true,
      right: false,
      bottom: false,
      child: WebviewScaffold(
        url: selectedUrl,
        //javascriptMode: JavascriptMode.unrestricted,

        withZoom: false,
        withLocalStorage: true,
        clearCookies: false,
      ),
    );
  }
}


/*
*
* */
