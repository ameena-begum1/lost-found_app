import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_compare/image_compare.dart';

Future<bool> areImagesSimilar(Uint8List img1Bytes, Uint8List img2Bytes) async {
  try {
    final img1 = img.decodeImage(img1Bytes);
    final img2 = img.decodeImage(img2Bytes);

    if (img1 == null || img2 == null) return false;

    final diff = await compareImages(src1: img1, src2: img2);
    print("Image diff: ${diff * 100}%");

    return diff < 0.05; 
  } catch (e) {
    print("Image comparison failed: $e");
    return false;
  }
}
