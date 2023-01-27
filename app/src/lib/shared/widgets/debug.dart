import 'package:flutter/material.dart';
import 'package:art_app_fyp/store/appstate.dart';
import 'package:flutter_redux/flutter_redux.dart';

/// Bottom sheet debug text
class MyDebug extends StatelessWidget {
  final bool debugState;
  final List<Widget> children;
  final double spacing;

  const MyDebug(
      {Key? key,
      required this.debugState,
      this.children = const <Widget>[],
      this.spacing = 25})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!debugState) {
      return const SizedBox.shrink();
    }

    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) =>
            Wrap(spacing: spacing, children: children));
  }
}
