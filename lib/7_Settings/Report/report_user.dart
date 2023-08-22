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
      resizeToAvoidBottomInset: true,
      appBar: null,
      body: CustomTitle(
          title: CustomEasyTitle(
            title: Text(widget.title, style: Provider.of<ThemeNotifier>(context).getTheme.textTheme.titleMedium),
            back: true,
          ),
          child: SingleChildScrollView( child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 5,),
              Container(
                color: CustomTheme.grey, width: MediaQuery.of(context).size.width,
                child: Padding(padding: const EdgeInsets.all( 10),
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Username",style:  TextStyle(fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.normal)) ,
                            Text(widget.userText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                              maxLines: 1,
                            ),
                          ]
                      ))
                  ),),
              const SizedBox(height: 5,),
              Container(
                color: CustomTheme.grey, width: MediaQuery.of(context).size.width,
                child: Padding(padding: const EdgeInsets.all( 10),
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Message",style:  TextStyle(fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.normal)) ,
                            TextFormField(
                              textAlign: TextAlign.start,
                              keyboardType: TextInputType.multiline,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                              decoration: const InputDecoration(hintText: "Write your message hear"),
                              maxLines: 10,
                              maxLength: 1000,
                              controller: controller,
                              validator: (v) => v != null && v.length < 2
                                  ? "Text must be longer than one characters"
                                  : null,
                            ),
                          ]
                      )
                  ),),),
            ],
          )),),
      floatingActionButton: FloatingActionButton(
        onPressed: submitReport,
        child: const Icon(Icons.send),
      ),
    );
  }

  Future<void> submitReport() async {
    if (controller.text.length > 1) {
      FetchUsers.postReportUser(widget.content, controller.text);
      Navigator.pop(context);
    }
  }
}
