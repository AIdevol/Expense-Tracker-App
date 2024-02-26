import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String trailing;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;

  const MyListTile({
    Key? key,
    required this.title,
    required this.trailing,
    required this.onEditPressed,
    required this.onDeletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: onEditPressed,
              icon: Icons.settings,
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            SlidableAction(
                onPressed: onDeletePressed,
                icon: Icons.delete,
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                borderRadius: BorderRadius.circular(4)),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200),
          child: ListTile(
            title: Text(title),
            trailing: Text(trailing),
          ),
        ),
      ),
    );
  }
}
