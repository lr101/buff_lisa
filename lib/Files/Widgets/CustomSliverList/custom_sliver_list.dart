import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_easy_title.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CustomSliverList extends StatefulWidget {

  final CustomEasyTitle title;
  final Widget appBar;
  final double appBarHeight;
  final PagingController<dynamic, Widget> pagingController;
  final Future<bool?> Function()? initPagedList;

  const CustomSliverList({
    super.key,
    required this.title,
    required this.appBar,
    required this.pagingController,
    this.appBarHeight = 100,
    this.initPagedList
  });

  static CustomSliverList builder({required CustomEasyTitle title,required Widget appBar,required int itemCount, double? appBarHeight, required Widget Function(int index) itemBuilder}) {
    PagingController<dynamic, Widget> controller = PagingController(firstPageKey: 0, invisibleItemsThreshold: 50);
    controller.addPageRequestListener((pageKey) {
      if (pageKey + 50 < itemCount) {
        controller.appendPage(List.generate(50, (index) => itemBuilder(index + pageKey as int)), pageKey + 50);
      } else {
        controller.appendLastPage(List.generate(itemCount - pageKey as int, (index) => itemBuilder(index + pageKey as int)));
      }
    });
    return CustomSliverList(title: title, appBar: appBar, pagingController: controller, appBarHeight: appBarHeight ?? 100);
  }

  @override
  CustomSliverListState createState() => CustomSliverListState();
}

class CustomSliverListState extends State<CustomSliverList> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child:
        Column(
        children: [
          widget.title,
          Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    toolbarHeight: 0,
                    collapsedHeight: 0,
                    expandedHeight: widget.appBarHeight,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      background: widget.appBar,
                    ),
                  ),
                  FutureBuilder<bool?>(
                    future: refreshList(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                      } else {
                        return PagedSliverList(
                          pagingController: widget.pagingController,
                          builderDelegate: PagedChildBuilderDelegate<Widget>(
                              animateTransitions: false,
                              itemBuilder: (context, item, index)  => item
                          ),
                        );
                      }
                    },
                  )
                ],
              )
          )
        ]
      )
    );
  }

  Future<bool?> refreshList() {
    final result = widget.initPagedList != null ? widget.initPagedList!() : Future(() => true);
    widget.pagingController.refresh();
    return result;
  }
}