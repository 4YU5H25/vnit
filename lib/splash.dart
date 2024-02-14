import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vnit/blue.dart';
import 'package:vnit/bluetooth.dart';

class Splash extends StatefulWidget {
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Bluetooth.requestPermissions();
    Timer(const Duration(seconds: 5), () {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 255, 255, 255),
        child: Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => BluetoothPage()));
            },
            child: Text("Proceed"),
          ),
        ),
      ),
    );
  }
}
