import 'package:buff_lisa/Files/DTOClasses/user.dart';
import 'package:buff_lisa/Files/Widgets/custom_round_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Other/global.dart' as global;
import '../DTOClasses/group.dart';
import '../Themes/custom_theme.dart';

class CustomListTile extends StatefulWidget {

  final Widget title;

  final Widget? subtitle;

  final Widget? leading;

  final Widget? trailing;

  final VoidCallback? onTab;

  final Color? backgroundColor;

  const CustomListTile({super.key, required this.title, this.subtitle, this.leading, this.trailing, this.onTab, this.backgroundColor});

  static CustomListTile fromUser(User user, int points, bool admin, void Function(String username) onTab) {
    TextStyle style = TextStyle(color: (global.localData.username == user.username) ? CustomTheme.c2 : null);
    return CustomListTile(
      leading: CustomRoundImage(
        size: 20,
        imageCallback: user.profileImage.asyncValue,
        clickable: false,
      ),
      title: Text(user.username, style: style),
      subtitle: Text("$points points", style: style),
      trailing: admin ? Text("admin", style: style) : null,
      onTab: () => onTab(user.username),
    );
  }

  static CustomListTile fromGroup(Group group, [VoidCallback? onTab, Color? backgroundColor]) {
    return CustomListTile(
      title: Text(group.name),
      subtitle: FutureBuilder<String?>(
        future: group.description.asyncValue(),
        builder: (context, snapshot) {
          if (snapshot.hasError || (snapshot.hasData && snapshot.requireData == null)) {
            return const Align(alignment: Alignment.centerLeft,child: Icon(Icons.lock, size: 12,));
          } else {
            return Text(snapshot.hasData ? snapshot.requireData! : "...", overflow: TextOverflow.clip, maxLines: 1,);
          }
        },
      ),
      leading: CustomRoundImage(
        size: 20,
        imageCallback: group.profileImage.asyncValue,
        clickable: false,
      ),
      onTab: onTab,
      backgroundColor: backgroundColor,
    );
  }

  @override
  CustomListTileState createState() => CustomListTileState();
}

class CustomListTileState extends State<CustomListTile> {


  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: widget.title,
      subtitle: widget.subtitle,
      leading: widget.leading,
      trailing: widget.trailing,
      onTap: widget.onTab,
      tileColor: widget.backgroundColor,
    );
  }

}