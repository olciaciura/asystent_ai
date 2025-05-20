import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:go_router/go_router.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(FlowerApp());
}

class FlowerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final GoRouter _router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => CameraScreen()),
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
            final responseMessage = state.extra as String;
            return PredictionScreen(responseMessage: responseMessage);
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Flower Application',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: _router,
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  File? _capturedPhoto;

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _initializeControllerFuture = _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    try {
      await _initializeControllerFuture;
      final image = await _cameraController.takePicture();
      setState(() {
        _capturedPhoto = File(image.path);
      });
      context.push(
        '/preview',
        extra: {'photo': _capturedPhoto, 'onSave': _savePhoto},
      );
    } catch (e) {
      print(e);
    }
  }

  Future<String> _sendPhotoToEndpoint(File photo) async {
    try {
      final uri = Uri.parse('https://small-szyc.fly.dev/predictions');
      var request = new http.MultipartRequest('POST', uri);
      final httpImage = http.MultipartFile.fromBytes(
        'image',
        photo.readAsBytesSync(),
        contentType: MediaType('image', 'jpeg'),
        filename: 'flower.jpg',
      );
      request.files.add(httpImage);
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return 'Success: $responseBody';
      } else if (response.statusCode == 422) {
        return 'Failed: Unprocessable Entity (422). Ensure the file is a valid JPG or JPEG.';
      } else {
        return 'Failed: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error sending photo: $e';
    }
  }

  void _savePhoto(BuildContext context) {
    if (_capturedPhoto != null) {
      log("jestem tu");
      _sendPhotoToEndpoint(_capturedPhoto!)
          .then((responseMessage) {
            if (mounted) {
              context.go('/prediction', extra: responseMessage);
            }
          })
          .catchError((error) {
            if (mounted) {
              context.go('/prediction', extra: 'Error: $error');
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flower Application')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_cameraController);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _capturePhoto,
        child: Icon(Icons.camera),
      ),
    );
  }
}

class PhotoPreviewScreen extends StatelessWidget {
  final File photo;
  final Function(BuildContext) onSave;

  PhotoPreviewScreen({required this.photo, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Photo Preview')),
      body: Column(
        children: [
          Expanded(
            child: kIsWeb ? Image.network(photo.path) : Image.file(photo),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  onSave(context);
                },
                child: Text('Save'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.pop();
                },
                child: Text('Discard'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PredictionScreen extends StatelessWidget {
  final String responseMessage;

  PredictionScreen({required this.responseMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prediction')),
      body: Center(
        child: Text(responseMessage, style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
