import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../9_Profile/profile_logic.dart';
import '../../Files/DTOClasses/group.dart';
import '../../Files/DTOClasses/ranking.dart';
import '../../Files/Routes/routing.dart';
import '../../Files/Widgets/CustomSliverList/custom_sliver_list.dart';
import '../../Files/Widgets/custom_list_tile.dart';
import '../../Providers/user_notifier.dart';

class MembersSubPage extends StatefulWidget {
  const MembersSubPage({super.key, required this.group, required this.myGroup});

  final Group group;

  final bool myGroup;

  @override
  MembersSubPageState createState() => MembersSubPageState();
}

class MembersSubPageState extends State<MembersSubPage> with AutomaticKeepAliveClientMixin<MembersSubPage>{

  PagingController<dynamic, Widget> controller = PagingController(firstPageKey: 0, invisibleItemsThreshold: 50);

  bool loaded = false;

  List<Ranking>? ranking;
  @override
  void initState() {
    controller.addPageRequestListener((pageKey) async {
      ranking ??= await ((widget.group.visibility != 0 && !widget.myGroup) ? Future(() => []) : widget.group.members.asyncValue());
      if (pageKey + 50 < ranking!.length) {
        controller.appendPage(List.generate(50, (index) => buildCard(index + pageKey as int)), pageKey + 50);
      } else {
        controller.appendLastPage(List.generate(ranking!.length - pageKey as int, (index) => buildCard(index + pageKey as int)));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return  CustomSliverList(
      pagingController: controller,
    );
  }

  Widget buildCard(int index) {
    Ranking member = ranking![index];
    return CustomListTile.fromUser(
        Provider.of<UserNotifier>(context, listen: false).getUser(member.username),
        member.points,
        member.username == widget.group.groupAdmin.syncValue,
        handleOpenUserProfile
    );
  }

  void handleOpenUserProfile(String username) {
    if (username == global.localData.username) return;
    Routing.to(context,  ProfilePage(username: username,));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

}