
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({Key? key}) : super(key: key);

  launchURL() async{
    final Uri url = Uri.parse("https://www.etsy.com/de/shop/MonaSticker");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.inAppWebView);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () {
          launchURL();
        },
        child: SizedBox (
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: const Center(
            child: Text(
              "PRESS TO LAUNCH SHOP",
              textAlign: TextAlign.center,
            ),
          ),
        )

      ),
    );
  }

}