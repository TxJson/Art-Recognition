// import 'package:flutter/material.dart';
// import 'package:art_app_fyp/classification/prediction.dart';

// /// Individual bounding box
// class BoxWidget extends StatelessWidget {
//   final Prediction prediction;

//   const BoxWidget(this.prediction);
//   @override
//   Widget build(BuildContext context) {
//     // Color for bounding box
//     Color color = Colors.primaries[(prediction.label.length +
//             prediction.label.codeUnitAt(0) +
//             prediction.id) %
//         Colors.primaries.length];

//     return Positioned(
//       left: prediction.renderBoundingBox.left,
//       top: prediction.renderBoundingBox.top,
//       width: prediction.renderBoundingBox.width,
//       height: prediction.renderBoundingBox.height,
//       child: Container(
//         width: prediction.renderBoundingBox.width,
//         height: prediction.renderBoundingBox.height,
//         decoration: BoxDecoration(
//             border: Border.all(color: color, width: 3),
//             borderRadius: const BorderRadius.all(Radius.circular(2))),
//         child: Align(
//           alignment: Alignment.topLeft,
//           child: FittedBox(
//             child: Container(
//               color: color,
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: <Widget>[
//                   Text(prediction.label),
//                   Text(
//                       ' ${(prediction.probability * 100).toStringAsFixed(2)}%'),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
