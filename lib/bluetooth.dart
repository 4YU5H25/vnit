import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class Bluetooth {
  static late BluetoothConnection? connection;
  static bool isConnected = false;
  static bool isScanning = false;
  static List<int> receivedDataList = [];
  static List<BluetoothDiscoveryResult> devices = [];
  static StreamSubscription<BluetoothDiscoveryResult>? streamSubscription;
  static int receivedData = 0; // Default value if parsing fails

  static List<BluetoothDevice> devicesList = [];

  static Future<void> startDiscovery() async {
    try {
      FlutterBluetoothSerial.instance.startDiscovery();
    } catch (ex) {
      print(ex);
    }

    FlutterBluetoothSerial.instance
        .startDiscovery()
        .listen((BluetoothDiscoveryResult state) {
      devicesList.add(state.device);
    });
  }

  static Future<void> connectToDevice(String address) async {
    Bluetooth.connection = await BluetoothConnection.toAddress(address);
    String pass = '1234';
    pass = pass.trim();
    try {
      List<int> list = pass.codeUnits;
      Uint8List bytes = Uint8List.fromList(list);
      connection!.output.add(bytes);
      await connection!.output.allSent;
      isConnected = true;
      print('Connected to Device');

      // connection!.input!.listen((Uint8List data) {
      //   // Concatenate the received data
      //   receivedData += String.fromCharCodes(data);

      //   // Check if the complete message is received
      //   if (receivedData.endsWith('\n')) {
      //     receivedData = receivedData.trim();

      //     try {
      //       print('Received Data: $receivedData');
      //       double parsedData = int.parse(receivedData.trim()) / 10;
      //       receivedDataList.add(parsedData);
      //       print("parsed hehe: $parsedData");
      //       print('Received Data packet: ${data.join(', ')}');
      //       print(receivedDataList);
      //       // Reset receivedData for the next message
      //       receivedData = '';
      //     } catch (e) {
      //       print('Error parsing data: $receivedData');
      //       // Handle the error as needed
      //     }

      // Reset receivedData for the next message
      // receivedData = '';
      // }
      // }, onDone: () {
      //   isConnected = false;
      // });
    } catch (exception, stackTrace) {
      print('Cannot connect, exception occurred: $exception');
      print('StackTrace: $stackTrace');
    }
  }

  void sendData(String data) async {
    data = data.trim();
    if (isConnected) {
      try {
        List<int> list = data.codeUnits;
        Uint8List bytes = Uint8List.fromList(list);
        connection!.output.add(bytes);
        await connection!.output.allSent;
        if (kDebugMode) {
          print('Data sent successfully');
        }
      } catch (e) {
        print('Error sending data: $e');
      }
    } else {
      print('BlConnection not yet initialized');
    }
  }

  static void startListening() {
    connection!.input!.listen(
      (Uint8List data) {
        if (data.length >= 4) {
          receivedData = 0;
          String rec = String.fromCharCodes(data);
          print("rec: $rec");
          List<int> asciiValues = [];

          for (int i = 0; i < 3; i++) {
            int asciiValue = rec.codeUnitAt(i);
            if (asciiValue < 0) {
              break;
            }
            int ind = int.parse(rec[i]);
            print("ind is: $ind");
            int x = asciiValue - '0'.codeUnitAt(0);
            asciiValues.add(x);
            receivedData = receivedData * 10 + ind;
          }

          print("integer: $receivedData");
          print("ascii : $asciiValues"); // Output: [1, 2, 3]
          // ByteData byteData = ByteData.sublistView(data);
          // receivedData = byteData.getInt32(0, Endian.little);
        }
      },
      onDone: () {
        print('Connection closed');
        connection = null;
      },
    );
  }

  static void stopBluetooth() {
    if (connection != null) {
      connection!.dispose();
      connection = null;
      print('Bluetooth Blconnection stopped');
    }
  }

  static Future<void> requestPermissions() async {
    await requestConnectPermission();
    await requestBluetoothPermission();
    await requestLocationPermission();
    await requestBluetoothScanPermission();
  }

  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.request();

    if (status == PermissionStatus.granted) {
      // Permission granted, you can access storage
      print('Storage permission granted');
      return true;
    } else if (status == PermissionStatus.denied) {
      // Permission denied
      print('Storage permission denied');
      return false;
    } else if (status == PermissionStatus.permanentlyDenied) {
      // Permission permanently denied
      print('Storage permission permanently denied. Open app settings.');
      await openAppSettings();
      return false;
    }

    // If status is restricted, unavailable, or limited, handle accordingly
    return false;
  }

  static Future<void> requestLocationPermission() async {
    // Request location permission
    var status = await Permission.location.request();

    if (status.isGranted) {
      // Permission granted, you can proceed with location-related tasks
      print("Location permission granted");
    } else if (status.isDenied) {
      // Permission denied, handle accordingly
      print("Location permission denied");
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  static Future<void> requestConnectPermission() async {
    // Request location permission
    var status = await Permission.bluetoothConnect.request();

    if (status.isGranted) {
      // Permission granted, you can proceed with location-related tasks
      print("Location permission granted");
    } else if (status.isDenied) {
      // Permission denied, handle accordingly
      print("Location permission denied");
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, navigate to app settings
      openAppSettings();
    }
  }

  static Future<void> requestBluetoothPermission() async {
    var status = await Permission.bluetooth.request();

    if (status.isGranted) {
      // Permission granted, you can proceed with Bluetooth-related tasks
      print("Bluetooth permission granted");
    } else if (status.isDenied) {
      // Permission denied, handle accordingly
      print("Bluetooth permission denied");
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, navigate to app settings
      openAppSettings();
    }
  }

  static Future<void> requestBluetoothScanPermission() async {
    var status = await Permission.bluetoothScan.request();

    if (status.isGranted) {
      // Permission granted, you can proceed with Bluetooth-related tasks
      print("Bluetooth permission granted");
    } else if (status.isDenied) {
      // Permission denied, handle accordingly
      print("Bluetooth permission denied");
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, navigate to app settings
      openAppSettings();
    }
  }
}
