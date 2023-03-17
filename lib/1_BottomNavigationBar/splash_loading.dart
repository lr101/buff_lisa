import 'package:buff_lisa/1_BottomNavigationBar/loading_notifier.dart';
import 'package:buff_lisa/Files/Widgets/custom_round_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashLoading extends StatefulWidget {
  const SplashLoading({super.key});

  @override
  SplashLoadingState createState() => SplashLoadingState();
}

class SplashLoadingState extends State<SplashLoading> with TickerProviderStateMixin {

  late AnimationController controller;
  bool determinate = false;

  @override
  void initState() {
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
      setState(() {});
    });
    controller.repeat();
    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<LoadingNotifier>(context).addListener(() { Navigator.of(context).pop();});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CustomRoundImage(asset: "images/pinGui.png", size: 50),
            const SizedBox(height: 30),
            const Text(
              'Loading your group information',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            LinearProgressIndicator(
              value: controller.value,
              semanticsLabel: 'Linear progress indicator',
            ),
          ],
        ),
      ),
    );
  }

}