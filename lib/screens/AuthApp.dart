import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_services.dart';

class AuthApp extends StatefulWidget {
  const AuthApp({Key? key}) : super(key: key);

  @override
  State<AuthApp> createState() => _AuthAppState();
}

class _AuthAppState extends State<AuthApp> {

  var _shopName = '';
  var _pin = '';
  bool _secure = true;
  bool _loading = false;

  TextEditingController _shopNameEditingController = TextEditingController();
  TextEditingController _pinEditingController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Puppet Vendors",
                  style: TextStyle(
                      fontSize: 26,
                      color: Color.fromRGBO(0, 0, 0, 1),
                      fontWeight: FontWeight.bold,
                      wordSpacing: 2,
                      letterSpacing: 1.2),
                )
              ],
            ),
            const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 10),
                child: Text(
                  "Enter Shop name and 6 digit pin from Web Admin Dashboard to Authenticate",
                  style: TextStyle(
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                )),
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
                hintText: "Enter pin here",
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
              maxLength: 6,
            ),
            ElevatedButton(
              onPressed: () async {
                // Navigate back to first screen when tapped.
                setState((){
                  _loading = true;
                });
                try{
                  var response = await authenticate(_shopNameEditingController.text, _pinEditingController.text);
                  print(response);
                }catch(e){
                  print(e);
                }finally{
                  setState((){
                    _loading = false;
                  });
                }
              },
              child: _loading ? CircularProgressIndicator(color: Colors.white,) : Text('Authenticate !'),
              style: ElevatedButton.styleFrom(fixedSize: const Size(300, 50)),

            ),
          ],
        )),
      ),
    );
  }
}
