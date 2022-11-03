import 'package:buff_lisa/6_Shop/shop_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Files/global.dart' as global;

class ShopPage extends StatelessWidget {
  ShopPage({Key? key}) : super(key: key);

  @override
  Widget build(context) => ShopUI(widget: this,);

  final List<Image> images = [
    const Image(image: AssetImage('images/mona-shop-1.png'),),
    const Image(image: AssetImage('images/mona-shop-2.jpg'),),
    const Image(image: AssetImage('images/tornado-shop-1.jpg'),),
    const Image(image: AssetImage('images/tornado-shop-2.png'),),

  ];

  /// copies the shop url to clipboard and shows a toast
  copyToClip() {
    Clipboard.setData(ClipboardData(text: global.shopUrl));
    Fluttertoast.showToast(
        msg: "Shop URL copied to clipboard",  // message
        toastLength: Toast.LENGTH_SHORT, // length
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
    );
  }


}