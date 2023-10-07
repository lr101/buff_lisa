import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_easy_title.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Files/Other/global.dart' as global;
import '../../Files/Widgets/custom_round_image.dart';
import '../../Providers/theme_provider.dart';
import '../../Providers/user_notifier.dart';
import 'check_image_logic.dart';

class CheckImageIU extends StatefulUI<CheckImageWidget, StateCheckImageWidget> {
  const CheckImageIU({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return CustomTitle.withoutSlivers(
            title: CustomEasyTitle(
              title: Text("Approve",
                  style: Provider.of<ThemeNotifier>(context)
                      .getTheme
                      .textTheme
                      .titleMedium),
              back: true,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    SizedBox(
                        height: 40,
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: CustomRoundImage(
                                      size: 16,
                                      imageCallback:
                                          Provider.of<UserNotifier>(context)
                                              .getUser(global.localData.username)
                                              .profileImageSmall
                                              .asyncValue,
                                      imageCallbackClickable:
                                          Provider.of<UserNotifier>(context)
                                              .getUser(global.localData.username)
                                              .profileImage
                                              .asyncValue,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 22,
                                        child: FittedBox(fit: BoxFit.fitHeight, child: Text(global.localData.username)),
                                      ),
                                      SizedBox(
                                          height: 18,
                                          child: FittedBox(fit: BoxFit.fitHeight, child:  Text(
                                            state.selectedGroup.name,
                                            style: const TextStyle(
                                                fontStyle: FontStyle.italic),
                                          )))
                                    ],
                                  )
                                ]),
                          ],
                        ),
                  ),
                  Expanded(
                    child: InteractiveViewer(
                      panEnabled: false,
                      transformationController: state.controller,
                      boundaryMargin: const EdgeInsets.all(0),
                      onInteractionEnd: (ScaleEndDetails endDetails) {
                        state.controller.value = Matrix4.identity();
                      },
                      minScale: 1,
                      maxScale: 4,
                      child: Image.memory(widget.image)
                  )),
                  const SizedBox(height: 5,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FloatingActionButton(
                        heroTag: "editCameraImage",
                        onPressed: state.handleEdit,
                        child: const Icon(Icons.edit),
                      ),
                      FloatingActionButton(
                        heroTag: "uploadCameraImage",
                        onPressed: state.handleApprove,
                        child: const Icon(Icons.check),
                      )
                    ],
                  )
                ],
              ),
            ));
  }
}
