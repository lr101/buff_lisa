import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_easy_title.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CustomSliverList extends StatefulWidget {

  final CustomEasyTitle title;
  final Widget appBar;
  final double appBarHeight;
  final PagingController<dynamic, Widget>? pagingController;
  final Future<bool?> Function()? initPagedList;
  final int? itemCount;
  final Widget Function(int index)? itemBuilder;

  const CustomSliverList({
    super.key,
    required this.title,
    required this.appBar,
    this.pagingController,
    this.itemCount,
    this.itemBuilder,
    this.appBarHeight = 100,
    this.initPagedList
  }) : assert(pagingController != null || (itemCount != null && itemBuilder != null));

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
                        return _list();
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

  Widget _list() {
    if (widget.pagingController != null) {
      return PagedSliverList(
        pagingController: widget.pagingController!,
        builderDelegate: PagedChildBuilderDelegate<Widget>(
            animateTransitions: false,
            itemBuilder: (context, item, index)  => item
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => widget.itemBuilder!(index),
          childCount: widget.itemCount!
        ),
      );
    }
  }

  Future<bool?> refreshList() {
    final result = widget.initPagedList != null
        ? widget.initPagedList!()
        : Future(() => true);
    if (widget.pagingController != null) {
      widget.pagingController!.refresh();
    } else {
      setState(() {});
    }
    return result;
  }
}