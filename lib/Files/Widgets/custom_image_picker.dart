import 'dart:typed_data';

import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../Themes/custom_theme.dart';
import 'custom_error_message.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

class CustomImagePicker {

  static Future<XFile?> pick({required BuildContext context}) async {


    try {
      if (!(await Permission.photos.isGranted)) {
        await Permission.photos.request();
      }
      if (!(await Permission.accessMediaLocation.isGranted)) {
        await Permission.accessMediaLocation.request();
      }
      // ImagePickerPlatform.instance.getImageFromSource(source: ImageSource.gallery, options: const ImagePickerOptions(imageQuality: 25, requestFullMetadata: true))
      return await ImagePicker().pickMedia(imageQuality: 25, requestFullMetadata: true);
    } catch (e) {
      CustomErrorMessage.message(context: context, message: "Something went wrong while trying to pick an image");
    }
    return null;
  }

  /// opens the input picker for selecting an image from the gallery
  /// after selecting an image it is opened in an image cropper
  /// check if 100 < width, height and image is square
  static Future<Uint8List?> pickAndCrop({required int minHeight, required int minWidth, required Color color, required BuildContext context}) async {
    try {
      final XFile? res =  await CustomImagePicker.pick(context: context);
      if (res != null && context.mounted) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: res.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Cropper',
                toolbarColor: CustomTheme.c1,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: true
            ),
            IOSUiSettings(
               title: 'Cropper',
               aspectRatioLockEnabled: true,
               aspectRatioLockDimensionSwapEnabled: false,
               aspectRatioPickerButtonHidden: true,
              resetAspectRatioEnabled: false,
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
      CustomErrorMessage.message(context: context, message: "Something went wrong while trying to pick an image");
    }
    return null;
  }
}