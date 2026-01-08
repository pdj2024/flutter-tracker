import 'dart:io';

import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  final File? imageFile;
  final String orientation;
  const ImageWidget({super.key, this.imageFile, this.orientation = 'square'});

  @override
  Widget build(BuildContext context) {
    print("Orientation: $orientation");
    return Center(
      child: Container(
        height: orientation == 'landscape' ? null : 300,
        width: double.infinity,
        margin: EdgeInsets.only(left: 50, right: 50, top: 50),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Color(0xff2fd5f2).withAlpha(30),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(imageFile!, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
