import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_easy_title.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../Providers/theme_provider.dart';

class ShowWebWidget extends StatefulWidget {
  const ShowWebWidget({super.key, required this.route, required this.title});

  final String route;
  final String title;

  @override
  State<ShowWebWidget> createState() => ShowWebWidgetState();
}

class ShowWebWidgetState extends State<ShowWebWidget> {
  WebViewController ini() {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setNavigationDelegate(
        NavigationDelegate(
            onProgress: (int progress) {},
            onPageStarted: (String url) {},
            onPageFinished: (String url) {},
            onWebResourceError: (WebResourceError error) {},
            onNavigationRequest: (NavigationRequest request) =>
                NavigationDecision.navigate),
      )
      ..loadRequest(Uri.parse(widget.route));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: CustomTitle(
        title: CustomEasyTitle(
          title: Text(widget.title,
              style: Provider.of<ThemeNotifier>(context)
                  .getTheme
                  .textTheme
                  .titleMedium),
          back: true,
        ),
        child: Column(children: [
          Expanded(child: WebViewWidget(controller: ini())),
        ]),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10),
        child: FloatingActionButton(
            onPressed: copyToClip, child: const Icon(Icons.copy)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  copyToClip() {
    Clipboard.setData(
        ClipboardData(text: 'https://${global.host}/${widget.route}'));
    Fluttertoast.showToast(
      msg: "${widget.title} url copied to clipboard", // message
      toastLength: Toast.LENGTH_SHORT, // length
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
    );
  }
}
