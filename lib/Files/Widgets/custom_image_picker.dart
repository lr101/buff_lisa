import 'dart:typed_data';
import 'dart:io';
import 'package:buff_lisa/Providers/create_group_notifier.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_cropping/image_cropping.dart';
import 'package:images_picker/images_picker.dart' as picker;
import 'package:provider/provider.dart';

class CustomImagePicker {

  /// opens the input picker for selecting an image from the gallery
  /// after selecting an image it is opened in an image cropper
  /// check if 100 < width, height and image is square
  static Future<Uint8List?> pick({required int minHeight, required int minWidth, required Color color, required BuildContext context}) async {
    try {
      List<picker.Media>? res = await picker.ImagesPicker.pick(
        count: 1,
        pickType: picker.PickType.image,
      );
      if (res != null && res.length == 1) {
        Uint8List? croppedBytes = await ImageCropping.cropImage(
          context: context,
          imageBytes: File(res[0].path).readAsBytesSync(),
          isConstrain: true,
          visibleOtherAspectRatios: false,
          selectedImageRatio: const CropAspectRatio(
            ratioX: 1,
            ratioY: 1,
          ),
          squareCircleColor: color,
          defaultTextColor: Colors.black,
          colorForWhiteSpace: Colors.black,
          outputImageFormat: OutputImageFormat.jpg,
          onImageDoneListener: (_) {},
        );
        if (croppedBytes == null) return null;
        final dimensions = await decodeImageFromList(croppedBytes);
        if ((dimensions.width < minHeight && dimensions.height < minHeight)) {
          return null;
        }
        return croppedBytes;
      }
    } catch (e) {
      //TODO show error message
    }
    return null;
  }
}