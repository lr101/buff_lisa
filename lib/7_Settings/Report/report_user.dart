import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Files/Themes/custom_theme.dart';
import '../../Files/Widgets/CustomSliverList/custom_easy_title.dart';

class ReportUser extends StatefulWidget {
  const ReportUser(
      {super.key,
      required this.content,
      required this.title,
      required this.hintText,
      required this.userText});

  final String content;
  final String title;
  final String hintText;
  final String userText;

  @override
  ReportUserState createState() => ReportUserState();
}

class ReportUserState extends State<ReportUser> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: CustomTitle(
          title: CustomEasyTitle(
            title: Text(widget.title, style: Provider.of<ThemeNotifier>(context).getTheme.textTheme.titleMedium),
            back: true,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(widget.userText, textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: controller,
                  maxLength: 500,
                  decoration:
                      InputDecoration.collapsed(hintText: widget.hintText),
                  maxLines: 5,
                  validator: (v) => v != null && v.length < 2
                      ? "Text must be longer than 10 characters"
                      : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextButton(
                  onPressed: () => submitReport(),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(color: CustomTheme.c1))),
                  ),
                  child: const Text("Submit reporting"),
                ),
              )
            ],
          )),
    );
  }

  Future<void> submitReport() async {
    if (controller.text.length > 10) {
      FetchUsers.postReportUser(widget.content, controller.text);
      Navigator.pop(context);
    }
  }
}
