import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Providers/theme_provider.dart';

class SearchNotifier with ChangeNotifier {

  SearchNotifier({required this.pullRefresh, required this.context}) {
    streamController.stream.listen((s) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        pullRefresh(textController.text);
      });
    });
    title = Text("Search Groups", style: Provider.of<ThemeNotifier>(context).getTheme.textTheme.titleMedium);
  }

  BuildContext context;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> Function(String? value) pullRefresh;

  /// icon shown in top right of app bar
  /// shows search icon if search is not active
  /// shows exit icon if search is active
  Icon icon = const Icon(Icons.search);

  late Widget title;

  Timer? _debounce;


  /// textController of search input field
  TextEditingController textController = TextEditingController();

  StreamController<String> streamController = StreamController();

  void toggle(bool filtered) {
    if (icon.icon == Icons.cancel) {
      icon = const Icon(Icons.search);
      title = Text("Search Groups", style: Provider.of<ThemeNotifier>(context, listen: false).getTheme.textTheme.titleMedium);
      textController.clear();
      if (filtered) pullRefresh(null);
    } else {
      icon = const Icon(Icons.cancel);
      title = Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(child: TextField(
              controller: textController,
              onChanged: (value) => streamController.add(value),
              onSubmitted: (value) => pullRefresh(value),
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'type a group name...',
                hintStyle: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
                border: InputBorder.none,
              ),
            ),)
          ]
      );
    }
    notifyListeners();
  }



}