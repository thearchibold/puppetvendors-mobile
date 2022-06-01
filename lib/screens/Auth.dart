import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pin_code_fields/pin_code_fields.dart';




class Auth extends StatelessWidget {
  const Auth({super.key});

  void toggleNav(){

  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Puppet Vendors",style: TextStyle(
                        fontSize: 26,
                        color: Color.fromRGBO(0, 0, 0, 1),
                        fontWeight: FontWeight.bold,
                      wordSpacing: 2,
                      letterSpacing: 1.2
                    ),)
                  ],
                ),
                const Padding(padding: EdgeInsets.only(
                  top: 20,
                  bottom: 10
                ), child: Text("Enter 6 digit pin from Web Admin Dashboard to Authenticate",
                  style: TextStyle(
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                )
                ),
                const TextField(
                  decoration: InputDecoration(
                      hintText: "Enter pin here",
                      labelText: "6 digit PIN",
                  ),
                  style: TextStyle(
                      fontSize: 20
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate back to first screen when tapped.
                    Navigator.pushNamed(context, '/splash');
                  },
                  child: const Text('Authenticate !'),
                ),

              ],
            )
        ),
      ),
    );
  }
}