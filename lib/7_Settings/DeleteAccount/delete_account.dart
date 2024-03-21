import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:buff_lisa/Files/Widgets/custom_error_message.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../0_ScreenSignIn/login_logic.dart';
import '../../Files/Other/global.dart' as global;
import '../../Files/Themes/custom_theme.dart';
import '../../Files/Widgets/CustomSliverList/custom_easy_title.dart';
import '../../Providers/cluster_notifier.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});


  @override
  DeleteAccountState createState() => DeleteAccountState();
}

class DeleteAccountState extends State<DeleteAccount> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
        bool test = await FetchUsers.getDeleteCode();
        if (test && mounted) {
          CustomErrorMessage.message(context: context, message: "Code successfully send");
        } else if (mounted) {
          CustomErrorMessage.message(context: context, message: "Error while sending code: \nAdd an email to your account");
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: CustomTitle(
          title: CustomEasyTitle(
            title: Text("Delete Account", style: Provider.of<ThemeNotifier>(context).getTheme.textTheme.titleMedium),
            back: true,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text("Type the Code from your email here:", textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: controller,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 20),
                  decoration: const InputDecoration.collapsed(hintText: "6 digit code"),
                  maxLines: 1,
                  validator: (v) => v != null && v.length == 6
                      ? "Code must have 6 digits"
                      : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextButton(
                  onPressed: () => submitDelete(),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(color: CustomTheme.c1))),
                  ),
                  child: const Text("Delete Your Account"),
                ),
              )
            ],
          )),
    );
  }

  Future<void> submitDelete() async {
    if (controller.text.length == 6) {
      bool test = await FetchUsers.deleteAccount(controller.text);
      if (!mounted) return;
      if (!test) {
        CustomErrorMessage.message(context: context, message: "Account deleting unsuccessfully");
      } else {
        Provider.of<ClusterNotifier>(context, listen: false).clearAll();
        await global.localData.logout();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const LoginScreen()
            ),
            ModalRoute.withName("/login")
        );
      }
    }
  }
}
