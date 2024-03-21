import 'package:buff_lisa/Files/Widgets/custom_error_message.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:buff_lisa/Providers/map_notifier.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:fading_image_button/fading_image_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Files/Other/global.dart' as global;
import '../../Files/Themes/custom_theme.dart';
import '../../Files/Widgets/CustomSliverList/custom_easy_title.dart';

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Short Tutorial:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                    GestureDetector(
                      onTap: () => launchUrl(Uri.parse("https://client.stadiamaps.com/signup/"),mode: LaunchMode.externalApplication),
                      child: const Text(
                        "1. Create an Stadia Maps account",  
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                            fontSize: 15
                        ),
                      ),
                    ),
                    const Text("2. Create 'Property' and finally click on 'Add API Key'", style: TextStyle(fontSize: 15),),
                    const Text("3. Copy API Key into field bellow", style: TextStyle(fontSize: 15),)
                  ],
                )
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 10),
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    hintText: "API-Key",
                    border: const UnderlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: submit,
                      icon: const Icon(Icons.save),
                    ),
                  ),
                  maxLines: 1,

                  ),
              ),
              Padding(padding: const EdgeInsets.all(10), child: GestureDetector(onTap: _launchUrl,
                  child: const Text.rich( //underline partially
                      TextSpan(
                          style: TextStyle(fontSize: 15), //global text style
                          children: [
                            TextSpan(text:"- More information: "),
                            TextSpan(text:"How to create an API Key", style: TextStyle(
                                decoration:TextDecoration.underline
                            )), //partial text style
                          ]
                      )
                  ),
              ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text("Select map style:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
              ),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                                onPressed: () =>  updateStyle(null),
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
                                onPressed: () =>  updateStyle(0),
                                onPressedImage: Image.asset("images/map0.png"),
                                height: MediaQuery.of(context).size.width / 5 * 0.75,
                                width: MediaQuery.of(context).size.width / 5,
                              ),
                            ),
                          ),
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
                                  onPressed: () =>  updateStyle(1),
                                  onPressedImage: Image.asset("images/map1.png"),
                                  height: MediaQuery.of(context).size.width / 5 * 0.75,
                                  width: MediaQuery.of(context).size.width / 5,
                                ),
                              )
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
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
                                onPressed: () =>  updateStyle(2),
                                onPressedImage: Image.asset("images/map2.png"),
                                height: MediaQuery.of(context).size.width / 5 * 0.75,
                                width: MediaQuery.of(context).size.width / 5,
                              ),
                            )
                          ),
                          Padding(
                              padding: const EdgeInsets.all(5),
                              child: Container(
                                decoration: BoxDecoration(
                                    border:Border.all(color: selected == 3 ?
                                    CustomTheme.c1 :
                                    Colors.grey)
                                ),
                                child: FadingImageButton(
                                  image: Image.asset("images/map3.png"),
                                  onPressed: () => updateStyle(3),
                                  onPressedImage: Image.asset("images/map3.png"),
                                  height: MediaQuery.of(context).size.width / 5 * 0.75,
                                  width: MediaQuery.of(context).size.width / 5,
                                ),
                              )
                          ),
                        ],
                      ),
                    ],
                  )
              ),
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
  }

  void updateStyle(int? num) {
    if (global.localData.getMapApiKey() != null) {
      setState(() {
        if (selected != num) {
          Provider.of<MapNotifier>(context, listen: false).setMapStyle(num);
          selected = num;
          CustomErrorMessage.message(
              context: context, message: "Map style successfully updated");
        }
      });
    } else {
      CustomErrorMessage.message(context: context, message: "Create own API-Key fist");
    }
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(Uri.parse("https://${global.host}/public/docs/stadia-key.pdf"),mode: LaunchMode.externalApplication)) {
    //Clipboard.setData(ClipboardData(text: "https://${global.host}/public/docs/stadia-key.pdf"));
    //                         CustomErrorMessage.message(context: context, message: "URL copied to clipboard");
  }
}
}
