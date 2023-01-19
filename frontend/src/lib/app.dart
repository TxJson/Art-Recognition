import 'package:flutter/material.dart';
import 'package:art_app_fyp/screens/list/main.dart';
import 'package:art_app_fyp/screens/home/main.dart';
import 'package:art_app_fyp/screens/favourite/main.dart';
import 'package:art_app_fyp/shared/utilities.dart';

enum AppPages {
  list(0),
  home(1),
  favourite(2);

  final int idx;
  const AppPages(this.idx);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  AppPages page = AppPages.home;

  Widget navigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      unselectedItemColor: getHexColor('#949494'),
      selectedItemColor: Colors.white,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: page.idx,
      onTap: (int index) => setState(() => page = AppPages.values[index]),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'Menu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline_outlined),
          label: 'Favourites',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Container();

    switch (page) {
      case AppPages.list:
        child = const MyList();
        break;
      case AppPages.home:
        child = const MyHome();
        break;
      case AppPages.favourite:
        child = const MyFavourite();
        break;
    }

    return Scaffold(
      body: SizedBox.expand(child: child),
      bottomNavigationBar: navigationBar(),
    );
  }
}
