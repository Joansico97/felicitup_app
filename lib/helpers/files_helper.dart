import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future pickImageFromGallery() async {
  final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

  if (pickedImage == null) return;

  return File(pickedImage.path);
}

Future pickImageFromCamera() async {
  final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);

  if (pickedImage == null) return;

  return File(pickedImage.path);
}

Future pickVideoFromCamera(BuildContext context) async {
  final orientation = MediaQuery.of(context).orientation;
  if (orientation == Orientation.landscape) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Por favor, graba el video en modo vertical',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    return;
  }

  final pickedVideo = await ImagePicker().pickVideo(
    source: ImageSource.camera,
    maxDuration: const Duration(seconds: 10),
  );

  if (pickedVideo == null) return;

  return File(pickedVideo.path);
}
