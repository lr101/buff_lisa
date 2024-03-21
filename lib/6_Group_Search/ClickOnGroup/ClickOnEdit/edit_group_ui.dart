import 'package:buff_lisa/6_Group_Search/ClickOnGroup/ClickOnEdit/edit_group_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_easy_title.dart';
import 'package:buff_lisa/Files/Widgets/custom_show_and_pick.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:buff_lisa/Providers/create_group_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Files/Themes/custom_theme.dart';
import '../../../Providers/theme_provider.dart';


class EditGroupUI extends StatefulUI<EditGroupPage, EditGroupPageState>{

  const EditGroupUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    TextEditingController t1 = Provider.of<CreateGroupNotifier>(context).getText1;
    TextEditingController t2 = Provider.of<CreateGroupNotifier>(context).getText2;
    TextEditingController t3 = Provider.of<CreateGroupNotifier>(context).getText3;
    return Scaffold(appBar: null,
        body: CustomTitle(
          title: CustomEasyTitle(
            title: Text("Edit Group", style: Provider.of<ThemeNotifier>(context).getTheme.textTheme.titleMedium),
            back: true,
          ),
          child: SingleChildScrollView(
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  color: CustomTheme.grey, width: MediaQuery.of(context).size.width,
                  child: Padding(padding: const EdgeInsets.all(10), child: Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: CustomShowAndPick(
                            size: 40,
                            iconSize: 15,
                            updateCallback: (p0, context) {
                              Provider.of<CreateGroupNotifier>(context, listen: false).setImage(p0);
                              return Future(() => p0);
                            },
                            provide: state.widget.group.profileImage.asyncValue,
                          ),
                        ),
                      const SizedBox(width: 10,),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 120,
                        child:
                        TextFormField(
                            textAlign: TextAlign.left,
                            decoration: const InputDecoration(hintText: "Type your group name"),
                            controller: t1
                        ),
                      )
                    ],
                  ),),),
                Container(
                  color: CustomTheme.grey, width: MediaQuery.of(context).size.width,
                  child: Padding(padding: const EdgeInsets.all( 10),
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Description:",style:  TextStyle(fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.normal)) ,
                              TextField(
                                textAlign: TextAlign.start,
                                keyboardType: TextInputType.multiline,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                                decoration: const InputDecoration(hintText: "Type your group description"),
                                maxLines: null,
                                controller: t2,
                              ),
                            ]
                        )
                    ),),),
                const SizedBox(height: 5,),
                Container(
                  color: CustomTheme.grey, width: MediaQuery.of(context).size.width,
                  child: Padding(padding: const EdgeInsets.all( 10),
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Url/Link:",style:  TextStyle(fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.normal)) ,
                              TextField(
                                textAlign: TextAlign.start,
                                keyboardType: TextInputType.url,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                ),
                                decoration: const InputDecoration(hintText: "Type your link (optional)"),
                                maxLines: 1,
                                controller: t3,
                              ),
                            ]
                        )
                    ),),),
                const SizedBox(height: 5,),
                Container(
                  color: CustomTheme.grey, width: MediaQuery.of(context).size.width,
                  child: Padding(padding: const EdgeInsets.all( 10),
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Group admin:",style:  TextStyle(fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.normal)) ,
                              DropdownButton(
                                  isExpanded: true,
                                  items: Provider.of<CreateGroupNotifier>(context, listen: false).menuItems,
                                  onChanged: (String? value) => Provider.of<CreateGroupNotifier>(context, listen: false).setCurrentItem(value!),
                                  value:  Provider.of<CreateGroupNotifier>(context).currentItem
                              ),
                            ]
                        )
                    ),),),
                const SizedBox(height: 5,),
                Container(
                    color: CustomTheme.grey, width: MediaQuery.of(context).size.width,
                    child: Padding(padding: const EdgeInsets.all(10), child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Group privacy (default public):", style:  TextStyle(fontSize: 14, fontStyle: FontStyle.italic, fontWeight: FontWeight.normal)),
                          Switch(
                            value: Provider.of<CreateGroupNotifier>(context).getSliderValue != 0,
                            onChanged: (value) => state.sliderOnChange(value ? 1 : 0, context),
                            focusColor: CustomTheme.c1,
                          ),
                        ],
                      ),
                    ),)
                )
              ],
            ),
          )
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => state.editGroup(context),
        child: const Icon(Icons.check),)
    );
  }


}