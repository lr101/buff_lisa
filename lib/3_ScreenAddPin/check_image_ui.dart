import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Files/global.dart' as global;
import 'check_image_logic.dart';

class CheckImageIU extends StatefulUI<CheckImageWidget, StateCheckImageWidget> {

  const CheckImageIU({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return FutureProvider<Widget>(
        create: (_) => state.handleFutureImage(),
        initialData: const Center(child: CircularProgressIndicator()),
        builder: ((context, child) => Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("Approve Image"),
            automaticallyImplyLeading: false,
            backgroundColor: global.cThird,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                  child:Consumer<Widget>(builder: (context, widget, child) => widget), //insert future image
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        //TODO choose group
                      ]
                  ),
                ),
                OutlinedButton(
                    onPressed: state.handleApprove,
                    style: OutlinedButton.styleFrom(
                      primary: global.cThird,
                      padding: const EdgeInsets.all(10),
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 40,
                      ),
                    ),
                    child: const Text("Approve")

                ),
                OutlinedButton(
                    onPressed: state.handleBack,
                    style: OutlinedButton.styleFrom(
                      primary: global.cFourth,
                      padding: const EdgeInsets.all(10),
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 40,
                      ),
                    ),
                    child: const Text("Back")
                )
              ],
            ),
          ),
        )
      )
    );
  }


}