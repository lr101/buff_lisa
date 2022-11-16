import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

import '../Files/DTOClasses/group.dart';
import '../Files/DTOClasses/pin.dart';

class FeedNotifier with ChangeNotifier {

  late List<Pin> sortedPins = [];
  late List<Pin> shownPins = [];


  List<Pin> get getSortedPins {
    return sortedPins;
  }
  List<Pin> get getShownPins {
    return shownPins;
  }

  void addToShownPins(Pin pin) {
    shownPins.add(pin);
    notifyListeners();
  }
  void _initShownPins() {
    for (int i = 0; i < sortedPins.length && i < 3; i++) {
      shownPins.add(sortedPins[i]);
    }
  }

  void initSortedPins(Set<Group> activeGroups) {
    sortedPins.clear();
    shownPins.clear();
    for (Group group in activeGroups) {
      sortedPins.addAll(group.pins);
    }
    sortedPins.sort((p1, p2) => -(p1.creationDate.compareTo(p2.creationDate)));
    _initShownPins();
  }

  void scrollFeed(double scroll, double height) {
    int numScrolled = (scroll / height).ceil();
    if (numScrolled == shownPins.length && sortedPins.length > shownPins.length) {
        shownPins.add(sortedPins[shownPins.length]);
        notifyListeners();
    }
  }

}