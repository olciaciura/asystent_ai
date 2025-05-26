import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'core/camera.dart';
import 'core/photo.dart';
import 'core/prediction.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(FlowerApp());
}

class FlowerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]); //blocks rotation
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode
          .immersiveSticky, // hides status bar and nav buttons, they can be revealed by swipe
    );
    final GoRouter _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => CameraScreen(cameras: cameras),
        ),
        GoRoute(
          path: '/preview',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final photo = extra['photo'] as File;
            final onSave = extra['onSave'] as Function(BuildContext);
            return PhotoPreviewScreen(photo: photo, onSave: onSave);
          },
        ),
        GoRoute(
          path: '/prediction',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final responseMessage = extra?['responseMessage'] as String?;
            final imagePath = extra?['imagePath'] as String?;

            return PredictionScreen(
              responseMessage: responseMessage,
              imagePath: imagePath,
            );
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Flower Application',
      theme: ThemeData(primarySwatch: Colors.blue),
      // home: CameraScreen(cameras: cameras),
      routerConfig: _router,
    );
  }
}
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//     ]); //blocks rotation
//     SystemChrome.setEnabledSystemUIMode(
//       SystemUiMode
//           .immersiveSticky, // hides status bar and nav buttons, they can be revealed by swipe
//     );
    // return MaterialApp(
    //   title: 'Flower Application',
    //   theme: ThemeData(primarySwatch: Colors.blue),
    //   home: CameraScreen(cameras: cameras),
    // );
//   }
// }
