import 'package:buff_lisa/7_Settings/settings_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_sliver_list.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../Files/Routes/routing.dart';
import '../Files/Themes/custom_theme.dart';
import '../Files/Widgets/CustomSliverList/custom_easy_title.dart';
import '../Files/Widgets/cusotm_alert_dialog.dart';
import 'WebView/show_web_widget.dart';

class SettingsUI extends StatelessUI<Settings> {

  const SettingsUI({super.key, required widget}) : super(widget: widget);

  @override
  Widget build(BuildContext context) {
    final con = context;
    return Scaffold(appBar: null,
      body: CustomTitle(
        title: CustomEasyTitle(
          title: Text("Settings", style: Provider.of<ThemeNotifier>(context).getTheme.textTheme.titleMedium),
          back: true,
        ),
        child: SettingsList(
          darkTheme: SettingsThemeData(settingsListBackground: Provider.of<ThemeNotifier>(context).getTheme.canvasColor),
          lightTheme: SettingsThemeData(settingsListBackground: Provider.of<ThemeNotifier>(context).getTheme.canvasColor),
            sections: [
              SettingsSection(
                title: const Text('App Settings'),
                tiles: [
                  SettingsTile.navigation(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    value: const Text('English'),
                  ),
                  SettingsTile.switchTile(
                    activeSwitchColor:  CustomTheme.c1,
                    onToggle: (value) => Provider.of<ThemeNotifier>(context, listen: false).toggleThemeMode(),
                    initialValue: Provider.of<ThemeNotifier>(context).getTheme.brightness == Brightness.dark,
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Toggle theme'),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.map),
                    title: const Text('Edit map'),
                    onPressed: (context) => widget.handleMapPress(context),
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
                      Routing.to(context, const ShowWebWidget(route: "public/privacy-policy",title: "Privacy Policy",));
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.document_scanner),
                    title: const Text('Terms of Service'),
                    onPressed: (context) {
                      Routing.to(context, const ShowWebWidget(route: "public/agb",title: "Terms of Service",));
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: const Text("Logout"),
                 tiles: [
                   SettingsTile.navigation(
                     leading: const Icon(Icons.delete, color: Colors.red),
                     title: const Text('Delete Account', style: TextStyle(color: Colors.red),),
                     onPressed: (context) => widget.handleDeleteAccount(context)
                   ),
                   SettingsTile.navigation(
                       leading: const Icon(Icons.logout, color: Colors.red),
                       title: const Text('Logout', style: TextStyle(color: Colors.red),),
                       onPressed: (context) =>  showDialog(
                           context: context,
                           builder: (context) =>  CustomAlertDialog(
                             title: "Confirm Logout",
                             text2: "Logout",
                             text1: "Cancel",
                             onPressed: () => widget.handleLogoutPress(con),
                           )
                       )
                   ),
                ]
              )
            ],
          ),
      )
    );
  }
}