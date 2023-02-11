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

  /// Widget shown in center of app bar
  /// shows title if search is not active
  /// shows text input of search if search is active
  Widget customSearchBar = Container();

  Widget title = const Text("Search Groups", style: TextStyle(fontSize: 20),);

  Timer? _debounce;


  /// textController of search input field
  TextEditingController textController = TextEditingController();

  StreamController<String> streamController = StreamController();

  /// called when search button is clicked
  /// open or removes search textfield in app bar
  Widget getWidget({required BuildContext context, required bool filtered})  {
      if (icon.icon == Icons.cancel) {
        title = const SizedBox.shrink();
        customSearchBar = SizedBox(
            width: MediaQuery.of(context).size.width - 100,
            child: ListTile(
              title: TextField(
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
              ),
            )
        );
      } else {
        icon = const Icon(Icons.search);
        customSearchBar = Container();
        title = const Text("Search Groups", style: TextStyle(fontSize: 20),);
        textController.clear();
        if (filtered) pullRefresh(null);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
        title,
        Row(
          children: [
            customSearchBar,
            IconButton(onPressed: toggle, icon: icon),
          ],
        )
      ],
    );
  }

  void toggle() {
    if (icon.icon == Icons.cancel) {
      icon = const Icon(Icons.search);
    } else {
      icon = const Icon(Icons.cancel);
    }
    notifyListeners();
  }



}