import 'package:flutter/material.dart';
import 'package:art_app_fyp/store/appstate.dart';
import 'package:flutter_redux/flutter_redux.dart';

/// Bottom sheet debug text
class DebugStatus extends StatelessWidget {
  final bool _debugState;
  final bool _debugTools;
  final List<Widget> _children;
  final double _spacing;

  const DebugStatus(
      {Key? key,
      required bool debugState,
      required bool debugTools,
      List<Widget> children = const <Widget>[],
      double spacing = 25})
      : _spacing = spacing,
        _children = children,
        _debugState = debugState,
        _debugTools = debugTools,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!_debugTools || !_debugState) {
      return const SizedBox.shrink();
    }

    List<Widget> children = [];
    for (int i = 0; i < _children.length; i++) {
      if (i > 0) {
        children.add(Text('■'));
      }

      children.add(_children[i]);
    }

    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) =>
            Wrap(spacing: _spacing, children: children));
  }
}
