import 'package:buff_lisa/7_Settings/AppSettings/settings_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/Widgets/CustomTitle.dart';

class SettingsUI extends StatelessUI<Settings> {

  const SettingsUI({super.key, required widget}) : super(widget: widget);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView(
        children: [
            const CustomTitle(
              titleBar: CustomTitleBar(
                title: "Settings",
                back: true,
              ),
            ),
            Card(
              child: TextButton(
                onPressed: () => widget.handleReportPost(context),
                child: const Text("Contact Developer", ),
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
          Card(
            child: TextButton(
              onPressed: () => widget.handlePasswordPress(context),
              child: const Text("Change Password", ),
            ),
          ),
          Card(
            child: TextButton(
              onPressed: () => widget.handleEmailPress(context),
              child: const Text("Change email", ),
            ),
          ),
          Card(
            child: TextButton(
              onPressed: () => widget.handleLogoutPress(context),
              child: const Text("Logout", ),
            ),
          ),
        ],
      )
    );
  }
}