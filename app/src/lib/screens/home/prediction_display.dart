import 'package:art_app_fyp/shared/helpers/prediction.dart';
import 'package:flutter/material.dart';

class PredictionDisplay extends StatelessWidget {
  final List<Prediction> _predictions;
  final bool _detectionState;

  PredictionDisplay(
      {required List<Prediction>? predictions, bool? detectionState})
      : _predictions = predictions ?? [],
        _detectionState = detectionState ?? true;

  String getPrediction() {
    if (_predictions.isEmpty || !_detectionState) {
      return 'None';
    }

    Prediction prediction = _predictions.last;
    return prediction.formatString();
  }

  @override
  Widget build(BuildContext context) {
    String predictionString = getPrediction();
    return Container(
        color: Colors.black,
        // margin: const EdgeInsets.only(top: 5, left: 15, right: 15),
        height: 60,
        width: MediaQuery.of(context).size.width,
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Detection',
                  style: TextStyle(fontSize: 20, color: Colors.white)),
              const SizedBox(height: 5),
              Text(
                predictionString,
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ]));
  }
}
