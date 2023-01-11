

import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:flutter/material.dart';
import '../Files/Other/global.dart' as global;
import '../Files/ServerCalls/restAPI.dart';

class ReportUser extends StatefulWidget {
  const ReportUser({super.key, required this.username, this.content});
  final String username;
  final String? content;

  @override
  ReportUserState createState() => ReportUserState();
}

class ReportUserState extends State<ReportUser>{

  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String title = widget.content == null ? 'Report User' : 'Report Content';
    String user = widget.content == null ? 'Report user: ${widget.username}' : 'Report content of user: ${widget.username}';
    String contentString = widget.content == null ? 'Why do you want to report ${widget.username}?' : 'Why do you want to report this content?';
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
        backgroundColor: global.cThird,
        automaticallyImplyLeading: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(user, textAlign: TextAlign.center),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: controller,
              maxLength: 500,
              decoration: InputDecoration.collapsed(
                  hintText: contentString
              ),
              maxLines: 5,
              validator: (v) => v != null && v.length < 11 ? "Text must be longer than 10 characters": null,
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
                        side: const BorderSide(color: Colors.blue)
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
      FetchUsers.postReportUser(widget.content == null ? widget.username : widget.content!, controller.text);
      Navigator.pop(context);
    }
  }




}