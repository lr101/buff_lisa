import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../Files/Other/global.dart' as global;

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
            onNavigationRequest: (NavigationRequest request) => NavigationDecision.prevent
        ),
      )
      ..loadRequest(Uri.parse('https://${global.host}/${widget.route}'));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: true,
      ),
      body: WebViewWidget(controller: ini()),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10),
        child: FloatingActionButton(onPressed: copyToClip, child: const Icon(Icons.copy)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  copyToClip() {
    Clipboard.setData(ClipboardData(text: 'https://${global.host}/${widget.route}'));
    Fluttertoast.showToast(
      msg: "${widget.title} url copied to clipboard",  // message
      toastLength: Toast.LENGTH_SHORT, // length
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
    );
  }



}