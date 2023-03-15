import 'package:flutter/material.dart';

class CustomEasyTitle extends StatefulWidget {
  const CustomEasyTitle({
    super.key,
    this.back = true,
    this.left,
    this.right,
    this.title,
    this.child
  });

  final bool back;
  final CustomEasyAction? left;
  final CustomEasyAction? right;
  final String? title;
  final Widget? child;

  @override
  CustomEasyTitleState createState() => CustomEasyTitleState();
}

class CustomEasyTitleState extends State<CustomEasyTitle> {


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: widget.child ?? Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox.square(dimension: 48, child: _left(),),
          _title(),
          SizedBox.square(dimension: 48, child:_right())
        ],
      ),
    );
  }

  Widget _left() {
    if (widget.back) {
      return IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back)
      );
    } else if (!widget.back && widget.left != null) {
      return  _action(widget.left!);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _title() {
    if (widget.title != null) {
      return Text(widget.title!, style: const TextStyle(fontSize: 20),);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _right() {
    if (widget.right != null) {
      return _action(widget.right!);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _action(CustomEasyAction action) {
    return TextButton(
      style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
              )
          )
      ),
      onPressed: () async {
        if (!action.loading) {
          try {
            setState(() {
              action.loading = true;
            });
            await action.action();
            setState(() {
              action.loading = false;
            });
          } finally {
            action.loading = false;
          }
        }
      },
      child: action.loading ? const CircularProgressIndicator() : SizedBox.square(dimension: 48, child: Center (child: action.child)),
    );
  }
}

class CustomEasyAction {

  CustomEasyAction({required this.child, required this.action});

  final Widget child;
  final Future<void> Function() action;
  bool loading = false;
}