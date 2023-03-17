import 'dart:async';

import 'package:flutter/material.dart';

class SearchNotifier with ChangeNotifier {

  SearchNotifier({required this.pullRefresh}) {
    streamController.stream.listen((s) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        pullRefresh(textController.text);
      });
    });
  }

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

  Widget title = const Text("Search Groups", style: TextStyle(fontSize: 20),);

  Timer? _debounce;


  /// textController of search input field
  TextEditingController textController = TextEditingController();

  StreamController<String> streamController = StreamController();

  void toggle(bool filtered) {
    if (icon.icon == Icons.cancel) {
      icon = const Icon(Icons.search);
      title = const Text("Search Groups", style: TextStyle(fontSize: 20),);
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