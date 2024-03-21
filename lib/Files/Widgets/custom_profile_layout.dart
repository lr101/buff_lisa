import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../Providers/theme_provider.dart';

class CustomProfileLayout extends StatefulWidget {
  const CustomProfileLayout({super.key, required this.image, required this.posts, this.members, this.ranking, this.children});

  final Widget image;
  final Widget posts;
  final Widget? members;
  final List<Widget>? ranking;
  final List<Widget>? children;

  @override
  CustomProfileLayoutState createState() => CustomProfileLayoutState();
}

class CustomProfileLayoutState extends State<CustomProfileLayout> {
  @override
  Widget build(BuildContext context) {
    return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: _children()
        );
  }

  Widget _top() {
    return Row(
      children: [
        const SizedBox(width: 56 - 25,), SizedBox(height: 100, width: MediaQuery.of(context).size.width - 56 - 25, child: Row(
        children: [
          widget.image,
          Expanded(child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                        child:  Align(alignment: Alignment.bottomCenter, child: widget.posts),
                    ),
                    Expanded(
                      flex: 1,
                      child: widget.members != null ?  Align(alignment: Alignment.bottomCenter, child: widget.members) : const SizedBox.shrink()
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Align(alignment: Alignment.topCenter, child: Text("posts")),
                    ),
                    Expanded(
                      flex: 1,
                      child: widget.members != null ? const Align(alignment: Alignment.topCenter, child: Text("members")) : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

            ],
          ))
        ],
    ))]);
  }

  List<Widget> _children() {
    List<Widget> widgets = [];
    widgets.add(_top());
    for (Widget child in widget.children ?? []) {
      widgets.add(_spaceBetween());
      widgets.add(Row(
        children: [
          const SizedBox(width: 56 - 25,), child
          ]
      ));
    }
    return widgets;
  }

  Widget _spaceBetween() {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Container(height: 5, width: MediaQuery.of(context).size.width, color: Provider.of<ThemeNotifier>(context).getTheme.canvasColor,));
  }

}