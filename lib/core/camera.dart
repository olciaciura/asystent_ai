import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
// import 'photo.dart';
// import 'prediction.dart';
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

      // Use GoRouter for navigation
      context.push(
        '/preview',
        extra: {'photo': photoFile, 'onSave': _savePhoto},
      );
    } catch (e) {
      log(e.toString());
    }
  }

  Future<String> _sendPhotoToEndpoint(File photo) async {
    try {
      final uri = Uri.parse('https://small-szyc.fly.dev/predictions');
      var request = http.MultipartRequest('POST', uri);
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

  void _predictionScreen() {
    // Use GoRouter for navigation
    context.go('/prediction');
  }

  void _savePhoto(BuildContext context) {
    if (_capturedPhoto != null) {
      _sendPhotoToEndpoint(_capturedPhoto!)
          .then((responseMessage) {
            if (mounted) {
              context.go(
                '/prediction',
                extra: {
                  'responseMessage': responseMessage,
                  'imagePath': _capturedPhoto!.path,
                },
              );
            }
          })
          .catchError((error) {
            log('Error sending photo: $error');
            if (mounted) {
              context.go(
                '/prediction',
                extra: {
                  'responseMessage': 'Error: $error',
                  'imagePath': _capturedPhoto!.path,
                },
              );
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Safely check _cameraController.value.isInitialized before accessing previewSize
            if (!_cameraController.value.isInitialized ||
                _cameraController.value.previewSize == null) {
              return const Center(child: Text('Camera preview not available'));
            }
            final previewSize = _cameraController.value.previewSize!;
            return Stack(
              children: [
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: previewSize.height,
                      height: previewSize.width,
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
