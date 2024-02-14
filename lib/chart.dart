import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Chart extends StatefulWidget {
  List<int> chartData;
  Chart({Key? key, required this.chartData}) : super(key: key);

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  late int _maxY;
  late int _minY;

  @override
  void initState() {
    super.initState();
    _updateMinMaxY();
  }

  @override
  void didUpdateWidget(covariant Chart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateMinMaxY();
  }

  void _updateMinMaxY() {
    _maxY = widget.chartData
        .reduce((curr, next) => curr > next ? curr + 20 : next + 20);
    _minY = widget.chartData.reduce((curr, next) => curr < next ? curr : next);
  }

  @override
  Widget build(BuildContext context) {
    final maxX = widget.chartData.length.toDouble();
    final minX = (maxX - 10)
        .clamp(0, double.infinity)
        .toDouble(); // Adjust the buffer space as needed

    return SizedBox(
      height: MediaQuery.of(context).size.height / 2,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
            gradient: const LinearGradient(
              colors: [Color(0xFF003366), Color(0xFF006699)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: LineChart(
            LineChartData(
              minX: minX,
              minY: _minY.toDouble(),
              maxX: maxX,
              maxY: _maxY.toDouble(),
              backgroundColor: const Color.fromARGB(125, 0, 0, 0),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  axisNameWidget: const Text(
                    "Length(cm)",
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 16,
                    ),
                  ),
                  axisNameSize: 18,
                ),
                bottomTitles: AxisTitles(
                  axisNameSize: 16,
                  axisNameWidget: const Text(
                    "Time(sec)",
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: const Color.fromARGB(0, 0, 24, 89),
                  width: 1,
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: widget.chartData
                      .asMap()
                      .entries
                      .map((entry) =>
                          FlSpot(entry.key.toDouble(), entry.value.toDouble()))
                      .toList(),
                  isCurved: true,
                  color: const Color.fromARGB(255, 228, 224, 0),
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                  shadow: BoxShadow(
                    color: const Color.fromARGB(255, 248, 255, 31)
                        .withOpacity(0.4),
                    blurRadius: 8.0,
                    spreadRadius: 4.0,
                  ),
                ),
              ],
            ),
            swapAnimationCurve: Curves.linear,
            swapAnimationDuration: const Duration(milliseconds: 500),
          ),
        ),
      ),
    );
  }
}
