import 'package:expense_tracker/bar%20graph/individual_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummery;
  final int startMonth;

  const MyBarGraph({
    super.key,
    required this.monthlySummery,
    required this.startMonth,
  });

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  List<IndividualBar> barData = [];

  void initializeBarData() {
    barData = List.generate(
      widget.monthlySummery.length,
      (index) => IndividualBar(
        x: index,
        y: widget.monthlySummery[index].toInt(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // initialize upon build
    initState()
    return BarChart(
      BarChartData(
          minY: 0,
          maxY: 100,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(
            show: true,
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true, getTitlesWidget: getBottomTitles),
            ),
          ),
          barGroups: barData
              .map(
                (data) => BarChartGroupData(
                  x: data.x,
                  barRods: [
                    BarChartRodData(
                      toY: data.y.toDouble(),
                    ),
                  ],
                ),
              )
              .toList()),
    );
  }
}

// Bottom titles
Widget getBottomTitles(double value, TitleMeta meta) {
  const textStyle = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );
  String text;
  switch (value.toInt()) {
    case 0:
      text = 'J';
      break;
    case 1:
      text = 'F';
      break;
    case 2:
      text = 'M';
      break;
    case 3:
      text = 'A';
      break;
    case 4:
      text = 'M';
      break;
    case 5:
      text = 'J';
      break;
    case 6:
      text = 'J';
      break;
    case 7:
      text = 'A';
      break;
    case 8:
      text = 'S';
      break;
    case 9:
      text = 'O';
      break;
    case 10:
      text = 'N';
      break;
    case 11:
      text = 'D';
      break;
    default:
      text = '';
      break;
  }
  return SideTitleWidget(
    child: Text(
      text,
      style: textStyle,
    ),
    axisSide: meta.axisSide,
  );
}
