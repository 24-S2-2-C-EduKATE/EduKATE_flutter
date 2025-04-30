// lib/picture_block/models/block_with_image.dart
import 'package:flutter_application_1/picture_block/models/block_data.dart';

class BlockWithImage {
  final String imagePath;
  final Shape shape;
  final String name;

  BlockWithImage({required this.imagePath, required this.shape, required this.name});
}