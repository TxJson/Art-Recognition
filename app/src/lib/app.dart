import 'package:art_app_fyp/shared/widgets/debugStatus.dart';
import 'package:art_app_fyp/store/appstate.dart';
import 'package:flutter/material.dart';
import 'package:art_app_fyp/screens/home/main.dart';
import 'package:art_app_fyp/shared/helpers/utilities.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';

enum AppPages {
  home(0);
  // settings(1);

  final int idx;
  const AppPages(this.idx);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
  // hello
}

class MyAppState extends State<MyApp> {
  AppPages page = AppPages.home;

  // Widget navigationBar() {
  //   return BottomNavigationBar(
  //     backgroundColor: Colors.black,
  //     unselectedItemColor: Utilities.getHexColor('#949494'),
  //     selectedItemColor: Colors.white,
  //     showSelectedLabels: false,
  //     showUnselectedLabels: false,
  //     currentIndex: page.idx,
  //     onTap: (int index) => setState(() => page = AppPages.values[index]),
  //     items: const <BottomNavigationBarItem>[
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.home_outlined),
  //         label: 'Home',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.settings),
  //         label: 'Settings',
  //       ),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    Widget child = Container();

    switch (page) {
      case AppPages.home:
        child = const MyHome();
        break;
      // case AppPages.settings:
      //   child = const MySettings();
      //   break;
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
        body: SizedBox.expand(child: child),
        bottomSheet: StoreConnector<AppState, dynamic>(
            converter: (store) => store.state,
            builder: (context, state) => DebugStatus(
                    debugState: state.debugState,
                    debugTools: state.debugTools,
                    spacing: 20,
                    children: <Widget>[
                      Text('Active Camera Index: ${state.activeCameraIndex}'),
                      Text(
                          'Detections: ${state.predictions?.length ?? "null"}'),
                      Text(
                          'Detection Status: ${state.detectionState ? 'On' : 'Off'}'),
                      Text('Active Model: ${state.models.getActive().name}')
                    ]))
        // bottomNavigationBar: navigationBar(),
        );
  }
}
