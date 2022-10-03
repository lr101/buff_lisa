
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({Key? key}) : super(key: key);

  launchURL() async{
    final Uri url = Uri.parse("https://www.etsy.com/de/shop/MonaSticker");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.inAppWebView);
    }
  }

  copyToClip() {
    Clipboard.setData(const ClipboardData(text: "https://www.etsy.com/de/shop/MonaSticker"));
    Fluttertoast.showToast(
        msg: "Shop URL copied to clipboard",  // message
        toastLength: Toast.LENGTH_SHORT, // length
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () {
          copyToClip();
        },
        child: SizedBox (
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: const Center(
            child: Text(
              "PRESS TO COPY SHOP URL TO CLIPBOARD\n\nURL = https://www.etsy.com/de/shop/MonaSticker",
              textAlign: TextAlign.center,
            ),
          ),
        )

      ),
    );
  }

}