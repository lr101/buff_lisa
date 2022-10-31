import 'package:flutter/material.dart';

class ProviderContext {

  late GlobalKey globalKey;
  bool mapBooted = false;
  late BuildContext context;

  ProviderContext(this.globalKey, this.context);

}
