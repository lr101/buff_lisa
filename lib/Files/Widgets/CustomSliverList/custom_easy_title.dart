import 'package:flutter/material.dart';
import 'package:measured_size/measured_size.dart';
import 'package:provider/provider.dart';
import '../../../Providers/theme_provider.dart';
import '../../Themes/custom_theme.dart';

class CustomEasyTitle extends SliverAppBar {
  const CustomEasyTitle({
    super.key,
    this.back = true,
    this.left,
    this.right,
    this.child,
    this.bottomWidget,
    this.bottomHeight = 55,
    title,
    this.customBackground = const SizedBox.shrink()
  }) : super (title: title);

  final bool back;
  final PreferredSizeWidget? bottomWidget;
  final CustomEasyAction? left;
  final CustomEasyAction? right;
  final Widget? child;
  final double bottomHeight;
  final Widget customBackground;

  @override
  CustomEasyTitleState createState() => CustomEasyTitleState();
}

class CustomEasyTitleState extends State<CustomEasyTitle> {

  final GlobalKey _childKey = GlobalKey();
  bool isHeightCalculated = false;
  late double height;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0.0,
      title: Consumer<ThemeNotifier>(builder: (context, value, child) => widget.title ?? const SizedBox.shrink()),
      backgroundColor: Color.alphaBlend(CustomTheme.grey, Provider.of<ThemeNotifier>(context).getTheme.canvasColor),
      leading: left(),
      pinned: true,
      forceElevated: true,
      actions: [right()],
      bottom: widget.bottomWidget,
      expandedHeight:  isHeightCalculated ? height : widget.bottomHeight + 5,
      flexibleSpace: FlexibleSpaceBar(
          stretchModes: const <StretchMode>[
            StretchMode.zoomBackground,
            StretchMode.blurBackground,
          ],
          background: Wrap(
            alignment: WrapAlignment.center,
            children: [
              MeasuredSize(
                child: Container(
                  color: Color.alphaBlend(CustomTheme.grey, Provider.of<ThemeNotifier>(context).getTheme.canvasColor),
                  child:Column(
                      key:  _childKey,
                      children: [
                        const SizedBox(height: 48,),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              widget.customBackground,
                              widget.bottomWidget != null ? Container(height: 5, color:  Provider.of<ThemeNotifier>(context).getTheme.canvasColor) : const SizedBox.shrink(),
                            ],
                          )
                        ),
                      ]),),
                onChange: (Size size) {
                  setState(() {
                    height = (_childKey.currentContext?.findRenderObject() as RenderBox).size.height;
                    height = height == 68.0 ? 0 : height;
                    height += widget.bottomHeight + 5;
                    isHeightCalculated = true;
                  });
                },
              ),
            ],
          )
      )
    );
  }

  Widget left() {
    if (widget.back) {
      return IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Provider.of<ThemeNotifier>(context).getTheme.iconTheme.color),
      );
    } else if (!widget.back && widget.left != null) {
      return  widget.left!.build();
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget right() {
    if (widget.right != null) {
      return widget.right!.build();
    } else {
      return const SizedBox.shrink();
    }
  }
}

class CustomEasyAction {

  CustomEasyAction({required this.child, this.action});

  final Widget child;
  final Future<void> Function()? action;
  bool loading = false;

  Widget build() {
    return TextButton(
      style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              )
          )
      ),
      onPressed: () async {
        if (action != null && !loading) {
          try {
              loading = true;
            await action!();
              loading = false;
          } finally {
            loading = false;
          }
        }
      },
      child: loading ? const CircularProgressIndicator() : SizedBox.square(dimension: 48, child: Center (child: child)),
    );
  }
}