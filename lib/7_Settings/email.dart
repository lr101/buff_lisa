import 'package:flutter/material.dart';
import '../Files/global.dart' as global;
import '../0_ScreenSignIn/login.dart';
import '../Files/restAPI.dart';

class Email extends StatelessWidget {
  const Email({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    final controller1 = TextEditingController();
    final controller2 = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Change Email'),
        backgroundColor: global.cThird,
      ),
      body: SizedBox(
          width: size,
          height: size,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Type Email:", style: TextStyle(color: global.cPrime)),
                SizedBox (
                  height: 50,
                  width: 200,
                  child: TextFormField(controller: controller1, style: const TextStyle(color: global.cPrime,))
                ),
                const Text("Repeat Email:", style: TextStyle(color: global.cPrime)),
                SizedBox (
                  height: 50,
                  width: 200,
                  child: TextFormField(controller: controller2,),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () => changeMail(controller1,controller2,context),
                        style: TextButton.styleFrom(backgroundColor: global.cThird),
                        child: const Text("Submit", style: TextStyle(color: Colors.white))
                    ),
                    const SizedBox(width: 10,),
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(backgroundColor: global.cFourth),
                        child: const Text("Cancel", style: TextStyle(color: Colors.white))
                    )
                  ],
                )
              ]
          )
      ),
    );
  }

  void changeMail(TextEditingController controller1, TextEditingController controller2, BuildContext context) {
    if (controller1.text == controller2.text &&  LoginScreen.emailValidator(controller1.text)) {
      RestAPI.changeEmail(global.username, controller1.text).then((value) => (value ? Navigator.pop(context) : null));
    }
  }
}