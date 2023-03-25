import 'package:flutter/material.dart';

class FooterButtons extends StatelessWidget {
  final void Function() _onPressed;
  final Color _foregroundColor;
  final Color _backgroundColor;
  final Icon _icon;
  final double _padding;
  final String _text;
  final Color _textColor;
  final bool _visible;

  const FooterButtons(
      {Color foregroundColor = Colors.white,
      Color backgroundColor = Colors.black,
      double? padding,
      String text = '',
      Color textColor = Colors.white,
      bool? visible,
      required Icon icon,
      required void Function() onPressed})
      : _textColor = textColor,
        _text = text,
        _visible = visible ?? true,
        _padding = padding ?? 5,
        _icon = icon,
        _backgroundColor = backgroundColor,
        _foregroundColor = foregroundColor,
        _onPressed = onPressed;

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: _visible,
        child: Column(children: <Widget>[
          Text(_text, style: TextStyle(color: _textColor)),
          SizedBox(height: _padding),
          FloatingActionButton(
            backgroundColor: _backgroundColor, // Maroon
            foregroundColor: _foregroundColor,
            onPressed: () => _onPressed(),
            child: _icon,
          )
        ]));
  }
}
