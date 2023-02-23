import 'dart:typed_data';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CustomImagePicker {

  /// opens the input picker for selecting an image from the gallery
  /// after selecting an image it is opened in an image cropper
  /// check if 100 < width, height and image is square
  static Future<Uint8List?> pick({required int minHeight, required int minWidth, required Color color, required BuildContext context}) async {
    try {
      final XFile? res =  await ImagePicker().pickImage(source: ImageSource.gallery);
      if (res != null && context.mounted) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: res.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Cropper',
                toolbarColor: Provider.of<ThemeProvider>(context, listen: false).getCustomTheme.c1,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: true
            ),
            IOSUiSettings(
              title: 'Cropper',
            ),
            WebUiSettings(
              context: context,
            ),
          ],
        );
        if (croppedFile == null) return null;
        Uint8List image = await croppedFile.readAsBytes();
        final dimensions = await decodeImageFromList(image);
        if ((dimensions.width < minHeight && dimensions.height < minHeight)) {
          return null;
        }
        return image;
      }
    } catch (e) {
      //TODO show error message
    }
    return null;
  }
}