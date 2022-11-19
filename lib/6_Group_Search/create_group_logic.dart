import 'dart:io';
import 'dart:typed_data';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:buff_lisa/Providers/create_group_notifier.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as dart_image;
import 'package:image_cropping/image_cropping.dart';
import 'package:images_picker/images_picker.dart' as picker;
import 'package:provider/provider.dart';
import '../Providers/cluster_notifier.dart';
import 'create_group_ui.dart';
import 'package:flutter/painting.dart' as painting;

//TODO Gruppen werden dobbelt ge-POST-tet
class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  CreateGroupPageState createState() => CreateGroupPageState();
}

class CreateGroupPageState extends State<CreateGroupPage> {
  @override
  Widget build(BuildContext context) {
    final state = this;
    return ChangeNotifierProvider<CreateGroupNotifier>(
      create: (_) {
      return CreateGroupNotifier();
      },
        builder: ((context, child) => CreateGroupUI(state: state))
    );
  }

  void sliderOnChange(double value, BuildContext context) {
    Provider.of<CreateGroupNotifier>(context, listen: false).setSliderValue(value);
  }

  void createGroup(BuildContext context) {
    final controller1 = Provider.of<CreateGroupNotifier>(context, listen: false).getText1;
    final controller2 = Provider.of<CreateGroupNotifier>(context, listen: false).getText2;
    final image = Provider.of<CreateGroupNotifier>(context, listen: false).getImage;
    final sliderValue = Provider.of<CreateGroupNotifier>(context, listen: false).getSliderValue;
    if (controller1.text.isNotEmpty && controller2.text.isNotEmpty && image != null) {
      RestAPI.postGroup(controller1.text, controller2.text, image, sliderValue.toInt()).then((group) {
        if (group != null) {
          Provider.of<ClusterNotifier>(context, listen:false).addGroup(group);
          Navigator.pop(context);
        }
      });
    }
  }

  Future<void> handleImageUpload(BuildContext context) async {
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
        squareCircleColor: Colors.red,
        defaultTextColor: Colors.black,
        colorForWhiteSpace: Colors.black,
        outputImageFormat: OutputImageFormat.jpg,
        onImageDoneListener: (_) {},
      );
      if(croppedBytes == null) return;
      final dimensions = await decodeImageFromList(croppedBytes);
      if ((dimensions.width < 100 && dimensions.height < 100) || dimensions.width != dimensions.height) return; //TODO error message -> picture to small
      if(!mounted) return;
      Provider.of<CreateGroupNotifier>(context, listen: false).setImage(croppedBytes);
    }
  }

  Widget getImageWidget(Uint8List? image) {
    if (image != null) {
      return Image.memory(image);
    } else {
      return const Icon(Icons.image);
    }
  }

}

