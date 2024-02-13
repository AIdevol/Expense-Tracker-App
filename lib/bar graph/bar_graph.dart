import 'package:expense_tracker/bar%20graph/individual_bar.dart';
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
        y: widget.monthlySummery[index],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
