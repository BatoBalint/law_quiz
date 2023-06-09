import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  const ListItem({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: getColor(text),
        child: Text(
          text,
        ),
      ),
    );
  }

  Color getColor(String input) {
    switch (text) {
      case "a":
        return Colors.blue;
      case "b":
        return Colors.pinkAccent;
      case "c":
        return Colors.yellow;
      case "d":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}
