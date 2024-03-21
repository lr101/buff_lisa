import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Providers/theme_provider.dart';
import '../Themes/custom_theme.dart';
import 'CustomSliverList/custom_easy_title.dart';

class CustomTitle extends StatefulWidget {
  const CustomTitle({
    super.key,
    this.sliverList,
    this.child,
    this.slivers,
    required this.title,
  }) : assert(sliverList != null || child != null || slivers != null);

  final Widget? sliverList;
  final Widget? child;
  final List<Widget>? slivers;
  final CustomEasyTitle title;

  static CustomTitle fromSlivers({required CustomEasyTitle title, required List<Widget> slivers}) {
    return CustomTitle(title: title, slivers: slivers);
  }

  static CustomTitle withoutSlivers({required CustomEasyTitle title, required Widget child}) {
    return CustomTitle(title: title, child: child);
  }

  static CustomTitle withSliverList({required CustomEasyTitle title, required Widget sliverList}) {
    return CustomTitle(title: title, sliverList: sliverList);
  }

  @override
  CustomTitleState createState() => CustomTitleState();
}

class CustomTitleState extends State<CustomTitle> {





  @override
  Widget build(BuildContext context) {
    if (widget.sliverList != null) {
      return Scaffold(
        backgroundColor: Color.alphaBlend(CustomTheme.grey, Provider.of<ThemeNotifier>(context).getTheme.canvasColor),
        body: SafeArea(
            child: _withList()
        )
      );
    } else if (widget.child != null) {
      return Scaffold(
        appBar: _normalAppBar(),
        body: _withChild()
      );
    } else {
      return Scaffold(
        body: _withSlivers()
      );
    }
  }

  Widget _withSlivers() {
    List<Widget> widgets = List.from(widget.slivers!);
    widgets.insert(0, widget.title);
    return  CustomScrollView(
      slivers: widgets
    );
  }

  Widget _withChild() {
    return Container(
      color: Provider.of<ThemeNotifier>(context).getTheme.canvasColor,
      child: widget.child
    );
  }

  PreferredSizeWidget _normalAppBar() {
    return AppBar(
      backgroundColor: Color.alphaBlend(CustomTheme.grey, Provider.of<ThemeNotifier>(context).getTheme.canvasColor),
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0.0,
      leading: left(),
      title: widget.title.title,
      actions: widget.title.right != null ? [widget.title.right!.build()] : null,
    );
  }

  Widget _withList() {
    return NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (context, innerScrolled) => <Widget>[
          SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: widget.title
          )
        ],
        body: Container(
          color: Provider.of<ThemeNotifier>(context).getTheme.canvasColor,
          child: Column(children: [Expanded(child: (widget.sliverList!))])
        )
    );
  }

  Widget left() {
    if (widget.title.back) {
      return IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back, color: Provider.of<ThemeNotifier>(context).getTheme.iconTheme.color),
      );
    } else if (!widget.title.back && widget.title.left != null) {
      return  widget.title.left!.build();
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget right() {
    if (widget.title.right != null) {
      return widget.title.right!.build();
    } else {
      return const SizedBox.shrink();
    }
  }
}
