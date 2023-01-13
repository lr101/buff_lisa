import 'package:buff_lisa/7_Settings/app_settings_logic.dart';
import 'package:buff_lisa/7_Settings/email_logic.dart';
import 'package:buff_lisa/7_Settings/profile_settings_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import '../Files/Other/global.dart' as global;

class AppSettingsUI extends StatelessUI<AppSettings> {

  const AppSettingsUI({super.key, required widget}) : super(widget: widget);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView(
        children: [
            SizedBox(
              height: 200,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                      ],
                    ),
                    const SizedBox(height: 18,),
                    const Text("App Settings", style: TextStyle(fontSize: 20),)
                  ]
              ),
            ),
            Card(
              child: TextButton(
                onPressed: () => widget.handleChangeTheme(context),
                child: const Text("Change Theme", ),
              ),
            ),
            Card(
              child: TextButton(
                onPressed: () => widget.handleHiddenPins(context),
                child: const Text("Edit hidden pins", ),
              ),
            ),
            Card(
              child: TextButton(
                onPressed: () => widget.handleHiddenUsers(context),
                child: const Text("Edit hidden users", ),
              ),
            ),
        ],
      )
    );
  }
}