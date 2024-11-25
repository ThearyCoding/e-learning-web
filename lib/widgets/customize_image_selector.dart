import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageSelector extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? imageUrl;
  final double height;
  final double width;
  final BoxFit fit;
  const ImageSelector({
    Key? key,
    this.imageBytes,
    this.imageUrl,
    this.height  = double.infinity,
    this.width = 200,
    this.fit = BoxFit.cover
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: height,
        width: width,
        child: imageBytes != null
            ? Image.memory(
                imageBytes!,
                height: height,
                width: width,
                fit: fit
              )
            : (imageUrl != null
                ? Image.network(
                    imageUrl!,
                    height: height,
                    width: width,
                    fit: fit,
                  )
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.transparent,
                      border: Border.all(color: Colors.grey),
                    ),
                    height: height,
                    width: width,
                    child: const Center(
                      child: Icon(
                        Icons.add_photo_alternate,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  )),
      ),
    );
  }
}