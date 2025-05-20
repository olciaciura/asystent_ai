import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'core/camera.dart';

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
    return MaterialApp(
      title: 'Flower Application',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CameraScreen(cameras: cameras),
    );
  }
}
