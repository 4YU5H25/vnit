import 'package:flutter/material.dart';
import 'package:vnit/splash.dart';
import 'bluetooth.dart';
import 'sync_chart.dart';

void main() {
  runApp(const MyApp());
  Bluetooth.requestPermissions();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Plotter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Splash(),
      debugShowCheckedModeBanner: false,
    );
  }
}
