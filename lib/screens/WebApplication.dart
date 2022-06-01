import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';



class WebApplication extends StatefulWidget {
  const WebApplication({Key? key}) : super(key: key);

  @override
  State<WebApplication> createState() => _WebApplication();
}

class _WebApplication extends State<WebApplication> {
  @override
  Widget build(BuildContext context) {
    String selectedUrl = "https://app.puppetvendors.com/shopify/install?shop=lilydale-3.myshopify.com";
    return SafeArea(
      left: false,
      top: true,
      right: false,
      bottom: false,
      child: WebView(
        initialUrl: selectedUrl,
        //withZoom: false,
        //withLocalStorage: true,
        //clearCookies: false,
      ),
    );
  }
}
