import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:asystent_ai/style/style.dart';

class PhotoPreviewScreen extends StatelessWidget {
  final File photo;
  final Function(BuildContext) onSave;

  PhotoPreviewScreen({required this.photo, required this.onSave, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child:
                kIsWeb
                    ? Image.network(photo.path, fit: BoxFit.cover)
                    : Image.file(photo, fit: BoxFit.cover),
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
              child: Text('Photo Preview', style: AppStyles.titleTextStyle),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 40,
            child: FloatingActionButton(
              heroTag: 'discard',
              backgroundColor: AppStyles.backgroundColor,
              foregroundColor: AppStyles.iconTheme.color,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.close, size: AppStyles.iconTheme.size),
              tooltip: 'Discard',
            ),
          ),

          Positioned(
            bottom: 20,
            right: 40,
            child: FloatingActionButton(
              heroTag: 'save',
              backgroundColor: AppStyles.backgroundColor,
              foregroundColor: AppStyles.iconTheme.color,
              onPressed: () {
                Navigator.pop(context);
                onSave(context);
              },
              child: Icon(Icons.check, size: AppStyles.iconTheme.size),
              tooltip: 'Save',
            ),
          ),
        ],
      ),
    );
  }
}
