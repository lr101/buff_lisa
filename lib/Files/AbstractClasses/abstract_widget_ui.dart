import 'package:flutter/cupertino.dart';

abstract class StatefulUI<T1, T2> extends StatelessWidget {
  final T2 state;

  T1 get widget => (state as State).widget as T1;

  const StatefulUI({super.key, required this.state});

  @override
  Widget build(BuildContext context);
}

abstract class StatelessUI<T1> extends StatelessWidget {
  final T1 widget;

  const StatelessUI({super.key, required this.widget});

  @override
  Widget build(BuildContext context);
}