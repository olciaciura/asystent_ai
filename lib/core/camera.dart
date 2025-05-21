import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'photo.dart';
import 'prediction.dart';
import 'package:asystent_ai/style/style.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  CameraScreen({required this.cameras});

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
      widget.cameras[0],
      ResolutionPreset.medium,
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
      final photoFile = File(image.path);
      _capturedPhoto = File(image.path);
      final imageProvider = FileImage(photoFile);
      final completer = Completer<void>();

      final imageStream = imageProvider.resolve(ImageConfiguration());
      final listener = ImageStreamListener(
        (info, _) {
          completer.complete();
        },
        onError: (error, _) {
          completer.complete();
        },
      );

      imageStream.addListener(listener);
      await completer.future;
      imageStream.removeListener(listener);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  PhotoPreviewScreen(photo: photoFile, onSave: _savePhoto),
        ),
      );
    } catch (e) {
      //print(e);
    }
  }

  void _predictionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PredictionScreen()),
    );
  }

  void _savePhoto(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PredictionScreen(imagePath: _capturedPhoto?.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _cameraController.value.previewSize!.height,
                      height: _cameraController.value.previewSize!.width,
                      child: CameraPreview(_cameraController),
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 50),
                    padding: AppStyles.padding,
                    decoration: BoxDecoration(
                      color: AppStyles.backgroundColor,
                      borderRadius: AppStyles.borderRadius,
                    ),
                    child: Text(
                      'Flower Application',
                      style: AppStyles.titleTextStyle,
                    ),
                  ),
                ),

                // Capture button
                Positioned(
                  bottom: 20,
                  left: MediaQuery.of(context).size.width / 2 - 28,
                  child: FloatingActionButton(
                    onPressed: _capturePhoto,
                    backgroundColor: AppStyles.backgroundColor,
                    foregroundColor: AppStyles.iconTheme.color,
                    child: Icon(Icons.camera, size: AppStyles.iconTheme.size),
                  ),
                ),

                // Prediction/chat button
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _predictionScreen,
                    backgroundColor: AppStyles.backgroundColor,
                    foregroundColor: AppStyles.iconTheme.color,
                    heroTag: 'chat',
                    child: Icon(Icons.chat),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
