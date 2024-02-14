// ChartScreen.dart

import 'package:flutter/material.dart';
import 'package:vnit/bluetooth.dart';
import 'Chart.dart';

class ChartScreen extends StatefulWidget {
  late String name, id, age, sex, visitno, weight, weightattached;
  ChartScreen({Key? key}) : super(key: key);
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  late bool receiving;

  List<int> chartData = [];

  @override
  void initState() {
    super.initState();
    receiving = true;
    chartData = [];
    startListeningAndUpdateChart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receiving == true ? "Recording..." : "Recorded"),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Divider(
                height: 40, // Adjust the height of the divider as needed
                thickness: 2, // Adjust the thickness of the divider as needed
                color: Colors.black,
              ),
              Center(
                child: Visibility(
                  visible: true,
                  child: Chart(
                    chartData: chartData,
                  ),
                ),
              ),
              const Divider(
                height: 40, // Adjust the height of the divider as needed
                thickness: 2, // Adjust the thickness of the divider as needed
                color: Colors.black,
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(
                  width: 320,
                  height: 76,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromHeight(60.0),
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.red,
                    ),
                    child: const Align(
                        alignment: Alignment.center, child: Text('STOP')),
                    onPressed: () async {
                      print("Stop  Button Pressed");
                      Navigator.pop(context);

                      // print("Chart data hehe: $chartData");

                      setState(() {
                        receiving = false;
                        chartData.clear();
                      });
                      // print("Data saved successfully");
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void startListeningAndUpdateChart() {
    Future<void> updateChart() async {
      // String newData = '';
      while (receiving) {
        int parsedData = Bluetooth.receivedData;

        chartData.add(parsedData);
        if (chartData.length > 30) {
          chartData.clear();
        }

        {
          print("parsedData Screen3: $parsedData");
          print("Chart data updated: $chartData");
        }

        Bluetooth.receivedData = 0;
        await Future.delayed(const Duration(milliseconds: 20));
      }
    }

    updateChart();
  }
}
