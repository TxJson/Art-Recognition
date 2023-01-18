import 'package:flutter/material.dart';

class MyFavourite extends StatelessWidget {
  const MyFavourite({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(color: Colors.red),
        child: const Center(
          child: Text('Favourite'),
        ));
  }
}
