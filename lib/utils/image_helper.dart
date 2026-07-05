import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Utilities for turning a picked image into a compressed base64 string that
/// fits inside a Firestore document, and rendering it back.
class ImageHelper {
  ImageHelper._();

  static final ImagePicker _picker = ImagePicker();

  /// Picks an image and returns it as a compressed base64 JPEG string.
  /// Returns null if the user cancels.
  static Future<String?> pickAsBase64({
    ImageSource source = ImageSource.gallery,
    double maxWidth = 900,
    int quality = 55,
  }) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      maxWidth: maxWidth,
      imageQuality: quality,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  static Uint8List? decode(String? data) {
    if (data == null || data.isEmpty) return null;
    try {
      return base64Decode(data);
    } catch (_) {
      return null;
    }
  }
}

/// Renders a base64 image with a graceful branded placeholder when empty.
class Base64Image extends StatelessWidget {
  final String? base64;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData placeholderIcon;
  final BorderRadius? borderRadius;

  const Base64Image({
    super.key,
    required this.base64,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderIcon = Icons.local_offer_outlined,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final bytes = ImageHelper.decode(base64);
    Widget child;
    if (bytes != null) {
      child = Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
      );
    } else {
      child = Container(
        width: width,
        height: height,
        color: Colors.grey.withValues(alpha: 0.15),
        alignment: Alignment.center,
        child: Icon(placeholderIcon, size: 40, color: Colors.grey[400]),
      );
    }
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }
}
