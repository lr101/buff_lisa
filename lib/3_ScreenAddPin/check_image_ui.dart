import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Files/Other/global.dart' as global;
import 'check_image_logic.dart';

class CheckImageIU extends StatefulUI<CheckImageWidget, StateCheckImageWidget> {

  const CheckImageIU({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: FutureProvider<Widget>(
              create: (_) => state.handleFutureImage(),
              initialData: const Center(child: CircularProgressIndicator()),
              builder: ((context, child) => Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: 200,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(onPressed: state.handleBack, icon: const Icon(Icons.arrow_back)),
                                  IconButton(onPressed: state.handleApprove, icon: const Icon(Icons.add_task)),
                                ],
                              ),
                              const SizedBox(height: 18,),
                              const Text("Approve Image", style: TextStyle(fontSize: 20),)
                            ]
                        ),
                      ),
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child:Consumer<Widget>(builder: (context, widget, child) => widget), //insert future image
                          )
                      ),
                    ],
                  ),
                ),
              )
              )
          )
      ),
    );
  }


}