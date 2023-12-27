import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddImageWidget extends StatefulWidget {
  const AddImageWidget(this.addImageFunc,{super.key});

  final Function(File pickedImage) addImageFunc;

  @override
  State<AddImageWidget> createState() => _AddImageWidgetState();
}

class _AddImageWidgetState extends State<AddImageWidget> {
  File? pickedImage;

  @override
  Widget build(BuildContext context) {

    
  void pickImage() async {
    final pickedImageFile = await ImagePicker().pickImage(source: ImageSource.gallery,imageQuality: 50, maxHeight: 150);
    
    setState(() {
      if (pickedImageFile != null){
          pickedImage = File(pickedImageFile.path);
      }
      
    });
    widget.addImageFunc(pickedImage!);
  }
  
    return Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                  backgroundImage: pickedImage != null ? FileImage(pickedImage!) : null,
                  
                  ),

                   TextButton.icon(
                // Button to pick an image
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Add Image'),
              ),
                ],
    );
  }
}