import 'package:art_app_fyp/shared/utilities.dart';
import 'package:flutter/material.dart';

// Modified from https://api.flutter.dev/flutter/material/CircularProgressIndicator-class.html
class Loader extends StatefulWidget {
  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final int milliseconds;
  final int microseconds;
  final Color color;
  final Color backgroundColor;
  final String message;

  const Loader(
      {this.days = 0,
      this.hours = 0,
      this.minutes = 0,
      this.seconds = 1,
      this.milliseconds = 0,
      this.microseconds = 0,
      this.color = Colors.red,
      this.backgroundColor = Colors.black,
      this.message = ''});

  @override
  State<Loader> createState() => LoaderState();
}

class LoaderState extends State<Loader> with TickerProviderStateMixin {
  late AnimationController controller;
  bool determinate = false;

  @override
  void initState() {
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: Duration(
          days: widget.days,
          hours: widget.hours,
          minutes: widget.minutes,
          seconds: widget.seconds,
          milliseconds: widget.milliseconds,
          microseconds: widget.microseconds),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: widget.backgroundColor,
        body: Align(
          alignment: Alignment.center,
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    semanticsLabel: 'loader',
                    color: widget.color,
                    value: controller.value,
                  ),
                  const SizedBox(height: 30),
                  Text(widget.message,
                      style: TextStyle(color: widget.color, fontSize: 20)),
                ],
              )),
        ));
  }
}
