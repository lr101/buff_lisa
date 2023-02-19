import 'package:flutter/cupertino.dart';

/// class to save information of the current context and bind it to a globally unique key
/// only used to save key of navbar
class NavBarContext {

  late GlobalKey globalKey;
  late BuildContext context;

  NavBarContext(this.globalKey, this.context);

}