import 'package:flutter/material.dart';

class FooterButtons extends StatelessWidget {
  final void Function() onPressed;
  final Color foregroundColor;
  final Color backgroundColor;
  final Icon icon;
  final double padding;
  final String text;
  final Color textColor;

  const FooterButtons(
      {this.foregroundColor = Colors.white,
      this.backgroundColor = Colors.black,
      this.padding = 10,
      this.text = '',
      this.textColor = Colors.white,
      required this.icon,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text(text, style: TextStyle(color: textColor)),
      SizedBox(height: padding),
      FloatingActionButton(
        backgroundColor: backgroundColor, // Maroon
        foregroundColor: foregroundColor,
        onPressed: () => onPressed(),
        child: icon,
      )
    ]);
  }
}
