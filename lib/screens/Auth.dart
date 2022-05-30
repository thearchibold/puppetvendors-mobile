import 'package:flutter/material.dart';




class Auth extends StatelessWidget {
  const Auth({super.key});

  void toggleNav(){

  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first screen when tapped.
            Navigator.pushNamed(context, '/splash');
          },
          child: const Text('Authenticate !'),
        ),
      ),
    );
  }


}