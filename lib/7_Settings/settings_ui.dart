import 'package:buff_lisa/7_Settings/settings_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';

import '../Files/Other/global.dart' as global;

class SettingsUI extends StatelessUI<Settings>  {
  const SettingsUI({super.key, required widget}) : super(widget: widget);

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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                      ],
                    ),
                    const SizedBox(height: 18,),
                    const Text("Settings", style: TextStyle(fontSize: 20),)
                  ]
              ),
            ),
            Card(
              child: TextButton(
                onPressed: () => widget.handlePasswordPress(context),
                child: const Text("Change Password", style: TextStyle(color: global.cPrime)),
              ),
            ),
            Card(
              child: TextButton(
                onPressed: () => widget.handleEmailPress(context),
                child: const Text("Change email", style: TextStyle(color: global.cPrime)),
              ),
            ),
            Card(
              child: TextButton(
                onPressed: () => widget.handleLogoutPress(context),
                child: const Text("Logout", style: TextStyle(color: global.cPrime)),
              ),
            ),
            Card(
              child: TextButton(
                onPressed: () => widget.handleChangeTheme(context),
                child: const Text("Change Theme", style: TextStyle(color: global.cPrime)),
              ),
            )
          ],
        )
    );
  }

}