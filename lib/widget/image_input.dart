import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onPickImage});

  final void Function(File image) onPickImage;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage;

  void _takePicture() {
    final imagePicker = ImagePicker();
    imagePicker.pickImage(source: ImageSource.camera, maxWidth: 600).then(
      (value) {
        if (value == null) {
          return;
        }
        setState(() {
          _selectedImage = File(value.path);
        });
        widget.onPickImage(_selectedImage!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
      onPressed: () {
        _takePicture();
      },
      icon: const Icon(Icons.camera),
      label: const Text("Take Picture"),
    );

    if (_selectedImage != null) {
      content = GestureDetector(
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.fill,
          height: double.infinity,
          width: double.infinity,
        ),
        onTap: (){
          _takePicture();
        },
      );
    }

    return Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
        ),
        alignment: Alignment.center,
        child: content);
  }
}
