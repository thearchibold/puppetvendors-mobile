import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:puppetvendors_mobile/main.dart';
import '../services/api_services.dart';

class AuthApp extends StatefulWidget {
  const AuthApp({Key? key}) : super(key: key);

  @override
  State<AuthApp> createState() => _AuthAppState();
}

class _AuthAppState extends State<AuthApp> {

  bool _secure = true;
  bool _loading = false;

  final TextEditingController  _shopNameEditingController = TextEditingController();
  final TextEditingController _pinEditingController = TextEditingController();

  void navigate(){
    navigatorKey.currentState?.pushNamed("/app");
  }

  void showMessage(var message){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 30),
                child: Text(
                  "Enter Shop name and 6 digit pin from Web Admin Dashboard to Authenticate",
                  style: TextStyle(
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
            ),
            TextField(
              controller: _shopNameEditingController,
              decoration: const InputDecoration(
                hintText: "e.g lilydale-3",
                labelText: "Shop name",
              ),
              style: const TextStyle(fontSize: 16),
              keyboardType: TextInputType.text,
              maxLength: 40,
            ),
            TextField(
              controller: _pinEditingController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9]')),
              ],
              decoration: InputDecoration(
                hintText: "436594",
                labelText: "6 digit PIN",
                suffixIcon: IconButton(
                  icon: _secure ? const Icon(Icons.remove_red_eye) : const Icon(Icons.security),
                  onPressed: () {
                   setState((){
                     _secure = !_secure;
                   });

                  },
                ),
              ),
              obscureText: _secure,
              style: const TextStyle(fontSize: 16),
              keyboardType: TextInputType.number,
              maxLength: 6
            ),
            ElevatedButton(
              onPressed: () async {
                if(_shopNameEditingController.text == ""){
                  showMessage("Please enter Shop name");
                  return;
                }
                if(_pinEditingController.text.length < 6){
                  showMessage("Please enter a valid PIN");
                  return;
                }
                // Navigate back to first screen when tapped.
                setState((){
                  _loading = true;
                });
                try{
                  var response = await authenticate(_shopNameEditingController.text, _pinEditingController.text);
                  GetStorage().write("vendor_id", response['vendor']['_id']);
                  GetStorage().write("shop_id", response['vendor']['shopId']);
                  //GetStorage().write("data", jsonEncode(response));
                  navigate();
                }catch(e){
                  showMessage(e.toString());
                }finally{
                  setState((){
                    _loading = false;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                  primary: const Color.fromRGBO(24, 92, 238, 1),
                  fixedSize: const Size(300, 50)),
              child: _loading ? const CircularProgressIndicator(color: Colors.white,) : const Text('Authenticate'),

            ),
          ],
        )),
      ),
    );
  }
}
