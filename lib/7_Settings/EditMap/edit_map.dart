import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:buff_lisa/Files/Widgets/custom_error_message.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:buff_lisa/Providers/map_notifier.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:fading_image_button/fading_image_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../Files/Other/global.dart' as global;
import '../../0_ScreenSignIn/login_logic.dart';
import '../../Files/Themes/custom_theme.dart';
import '../../Files/Widgets/CustomSliverList/custom_easy_title.dart';
import '../../Providers/cluster_notifier.dart';

class EditMap extends StatefulWidget {
  const EditMap({super.key});


  @override
  EditMapState createState() => EditMapState();
}

class EditMapState extends State<EditMap> {
  TextEditingController controller = TextEditingController();

  int? selected = global.localData.getMapStyle();
  int? start = global.localData.getMapStyle();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: CustomTitle(
          title: CustomEasyTitle(
            title: Text("Edit Map", style: Provider.of<ThemeNotifier>(context).getTheme.textTheme.titleMedium),
            back: true,
          ),
          child: SingleChildScrollView(

            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text("API-Key:", textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                  decoration: const InputDecoration.collapsed(hintText: "API-Key", border: UnderlineInputBorder()),
                  maxLines: 1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text("Select map style:", textAlign: TextAlign.center),
              ),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Container(
                              decoration: BoxDecoration(
                                  border:Border.all(color: selected == null ?
                                  CustomTheme.c1 :
                                  Colors.grey)
                              ),
                              child:FadingImageButton(
                                image: Image.asset("images/map.png"),
                                onPressed: () => setState(() {selected = null;}),
                                onPressedImage: Image.asset("images/map.png"),
                                height: MediaQuery.of(context).size.width / 5 * 0.75,
                                width: MediaQuery.of(context).size.width / 5,
                              ),
                            )
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Container(
                              decoration: BoxDecoration(
                                  border:Border.all(color: selected == 0 ?
                                  CustomTheme.c1 :
                                  Colors.grey)
                              ),
                              child:FadingImageButton(
                                image: Image.asset("images/map0.png"),
                                onPressed: () => setState(() {selected = 0;}),
                                onPressedImage: Image.asset("images/map0.png"),
                                height: MediaQuery.of(context).size.width / 5 * 0.75,
                                width: MediaQuery.of(context).size.width / 5,
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Container(
                              decoration: BoxDecoration(
                                  border:Border.all(color: selected == 1 ?
                                  CustomTheme.c1 :
                                  Colors.grey)
                              ),
                              child: FadingImageButton(
                                image: Image.asset("images/map1.png"),
                                onPressed: () => setState(() {selected = 1;}),
                                onPressedImage: Image.asset("images/map1.png"),
                                height: MediaQuery.of(context).size.width / 5 * 0.75,
                                width: MediaQuery.of(context).size.width / 5,
                              ),
                            )
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Container(
                              decoration: BoxDecoration(
                                  border:Border.all(color: selected == 2 ?
                                  CustomTheme.c1 :
                                  Colors.grey)
                              ),
                              child: FadingImageButton(
                                image: Image.asset("images/map2.png"),
                                onPressed: () => setState(() {selected = 2;}),
                                onPressedImage: Image.asset("images/map2.png"),
                                height: MediaQuery.of(context).size.width / 5 * 0.75,
                                width: MediaQuery.of(context).size.width / 5,
                              ),
                            )
                          ),
                        ],
                      ),
                      Align(
                        child:  Padding(
                          padding: const EdgeInsets.all(5),
                          child: Container(
                            decoration: BoxDecoration(
                                border:Border.all(color: selected == 3 ?
                                CustomTheme.c1 :
                                Colors.grey)
                            ),
                            child: FadingImageButton(
                              image: Image.asset("images/map3.png"),
                              onPressed: () => setState(() {selected = 3;}),
                              onPressedImage: Image.asset("images/map3.png"),
                              height: MediaQuery.of(context).size.width / 5 * 0.75,
                              width: MediaQuery.of(context).size.width / 5,
                            ),
                          )
                        ),
                      )
                    ],
                  )
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextButton(
                  onPressed: () => submit(),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(color: CustomTheme.c1))),
                  ),
                  child: const Text("Submit Changes"),
                ),
              ),
              Padding(padding: const EdgeInsets.all(20), child:
                    TextButton(onPressed: () {
                        Clipboard.setData(ClipboardData(text: "https://${global.host}/public/docs/stadia-key.pdf"));
                        CustomErrorMessage.message(context: context, message: "URL copied to clipboard");
                    },
                    child: const Text("How to create an API Key", style: TextStyle(decoration: TextDecoration.underline,),)))
            ],
          )),
      )
    );
  }

  void submit() async {
    if (controller.text.isNotEmpty && controller.text.length > 5) {
      Provider.of<MapNotifier>(context, listen: false).setMapApiKey(
          controller.text);
      CustomErrorMessage.message(context: context, message: "Api Key successfully updated");
    }

    if (selected != start) {
      Provider.of<MapNotifier>(context,listen: false).setMapStyle(selected);
      CustomErrorMessage.message(context: context, message: "Map style successfully updated");
    }
  }
}
