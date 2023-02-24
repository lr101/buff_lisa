import 'package:buff_lisa/6_Group_Search/ClickOnExplore/search_logic.dart';
import 'package:buff_lisa/6_Group_Search/ClickOnExplore/search_notifier.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';


class SearchUI extends StatefulUI<SearchGroupPage, SearchGroupPageState>{

  const SearchUI({super.key, required state}) : super(state: state);



  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: null,
        body: PagedListView<int, Group>(
          pagingController: state.pagingController,
          builderDelegate: PagedChildBuilderDelegate<Group>(
              newPageProgressIndicatorBuilder: (_) => const SizedBox.shrink(),
              animateTransitions: true,
              itemBuilder: (context, item, index) {
                if (index == 0) {
                  return getTitle(context);
                } else if (index == 1) {
                  return getCardCreateNewGroup();
                } else {
                  index -= 2;
                  return getCardOfOtherGroups(item, index);
                }
              }
          ),
        )
    );
  }

  Widget getTitle(BuildContext context) {
    return CustomTitle(
      titleBar: CustomTitleBar(
        actionBar: Provider.of<SearchNotifier>(context).getWidget(context: context, filtered: state.filtered)
      ),
    );
  }

  /// Get Card with button to navigate to create group page
  /// Is always at the first postion of the list
  Widget getCardCreateNewGroup() {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          onTap: state.handlePressNewGroup,
          title: const Text("Create a new group",),
          leading: const Icon(Icons.add),
          ),
        );
  }

  /// Get Card of a Group
  /// Shows the name, group image, visibility
  Widget getCardOfOtherGroups(Group group, int index) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: GestureDetector(
          onTap: () => state.handleJoinGroupPress(group),
          child: ListTile(
            leading: group.profileImage.customWidget(
                callback: (p0) => CircleAvatar(backgroundImage: Image.memory(p0).image, radius: 20),
                elseFunc: () => const CircleAvatar(backgroundColor: Colors.grey, radius: 20,)
            ),
            title: Text(group.name),
            trailing: (group.visibility != 0 ? const Icon(Icons.lock_outline) : const Icon(Icons.lock_open)),
          ),
        )
    );
  }

}