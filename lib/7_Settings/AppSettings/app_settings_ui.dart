import 'package:buff_lisa/7_Settings/AppSettings/app_settings_logic.dart';
import 'package:buff_lisa/7_Settings/ProfileSettings/email_logic.dart';
import 'package:buff_lisa/7_Settings/ProfileSettings/profile_settings_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/Widgets/CustomTitle.dart';

class AppSettingsUI extends StatelessUI<AppSettings> {

  const AppSettingsUI({super.key, required widget}) : super(widget: widget);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView(
        children: [
            const CustomTitle(
              title: "App Settings",
              back: true,
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