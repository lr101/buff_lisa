import 'package:flutter/material.dart';

class Tupel3 {
  final String name;
  final Widget widget;
  final Icon icon;

  Tupel3(this.name, this.widget, this.icon);

  Tab toTab() {
    return Tab(icon: icon, text: name, height: 56,);
  }
}