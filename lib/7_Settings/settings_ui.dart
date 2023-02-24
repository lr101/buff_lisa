import 'package:buff_lisa/7_Settings/settings_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../Files/Widgets/cusotm_alert_dialog.dart';
import 'WebView/show_web_widget.dart';

class SettingsUI extends StatelessUI<Settings> {

  const SettingsUI({super.key, required widget}) : super(widget: widget);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: null,
      body: SettingsList(
            sections: [
              const CustomSettingsSection(
                  child: CustomTitle(
                    titleBar: CustomTitleBar(title: "Settings"),
                  )
              ),
              SettingsSection(
                title: const Text('App Settings'),
                tiles: [
                  SettingsTile.navigation(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    value: const Text('English'),
                  ),
                  SettingsTile.switchTile(
                    activeSwitchColor:  Provider.of<ThemeProvider>(context).getCustomTheme.c1,
                    onToggle: (value) => Provider.of<ThemeProvider>(context, listen: false).toggleThemeMode(),
                    initialValue: Provider.of<ThemeProvider>(context).getTheme.brightness == Brightness.dark,
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Toggle theme'),
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('User Settings'),
                tiles: [
                  SettingsTile.navigation(
                    leading: const Icon(Icons.password),
                    title: const Text('Edit password'),
                    onPressed: (context) => widget.handlePasswordPress(context),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.email),
                    title: const Text('Edit email'),
                    onPressed: (context) => widget.handleEmailPress(context),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.hide_image),
                    title: const Text('Edit hidden posts'),
                    onPressed: (context) => widget.handleHiddenPins(context),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.hide_source),
                    title: const Text('Edit hidden users'),
                    onPressed: (context) => widget.handleHiddenUsers(context),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.reorder),
                    title: const Text('Order Groups'),
                    onPressed: (context) => widget.handleOrderGroups(context),
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('About'),
                tiles: [
                  SettingsTile.navigation(
                    leading: const Icon(Icons.contact_support),
                    title: const Text('Contact developer'),
                    onPressed: (context) => widget.handleReportPost(context),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.document_scanner),
                    title: const Text('Privacy Policy'),
                    onPressed: (context) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ShowWebWidget(route: "public/privacy-policy",title: "Privacy Policy",)),
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.document_scanner),
                    title: const Text('Terms of Service'),
                    onPressed: (context) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ShowWebWidget(route: "public/agb",title: "Terms of Service",)),
                      );
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: const Text("Logout"),
                 tiles: [
                   SettingsTile.navigation(
                     leading: const Icon(Icons.logout),
                     title: const Text('Logout'),
                     onPressed: (context) =>  showDialog(
                         context: context,
                         builder: (context) =>  CustomAlertDialog(
                           title: "Confirm Logout",
                           text2: "Logout",
                           text1: "Cancel",
                           onPressed: () => widget.handleLogoutPress(context),
                         )
                     )
                   ),
                ]
              )
            ],
          ),
    );
  }
}