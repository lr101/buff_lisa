

import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/ServerCalls/restAPI.dart';
import 'package:buff_lisa/Files/Widgets/CustomTitle.dart';

class ReportUser extends StatefulWidget {
  const ReportUser({super.key,required this.content, required this.title, required this.hintText, required this.userText});
  final String content;
  final String title;
  final String hintText;
  final String userText;

  @override
  ReportUserState createState() => ReportUserState();
}

class ReportUserState extends State<ReportUser>{

  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomTitle(
            titleBar: CustomTitleBar(
              title: widget.title,
              back: true,
            )
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(widget.userText, textAlign: TextAlign.center),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: controller,
              maxLength: 500,
              decoration: InputDecoration.collapsed(
                  hintText: widget.hintText
              ),
              maxLines: 5,
              validator: (v) => v != null && v.length < 2 ? "Text must be longer than 10 characters": null,
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
                        side: BorderSide(color: Provider.of<ThemeProvider>(context).getCustomTheme.c1)
                    )
                ),
              ),
              child: const Text("Submit reporting"),
            ),
          )
        ],
      ),
    );
  }

  Future<void> submitReport() async {
    if (controller.text.length > 10 ) {
      FetchUsers.postReportUser(widget.content, controller.text);
      Navigator.pop(context);
    }
  }




}