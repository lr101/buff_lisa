import 'package:buff_lisa/7_Settings/HiddenPins/hidden_pin_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:buff_lisa/Providers/hidden_pin_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class HiddenPin extends StatefulWidget {
  const HiddenPin({super.key});


  @override
  HiddenPinState createState() => HiddenPinState();
}

class HiddenPinState extends State<HiddenPin>{

  @override
  late BuildContext context;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<Group> groups = Provider.of<ClusterNotifier>(context, listen: false).getGroups;
      Provider.of<HiddenPinPageNotifier>(context, listen: false).loadOffline(groups);
    });
  }

  /// adds a ChangeNotifierProvider to the build
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HiddenPinPageNotifier>(create: (_) {
      return HiddenPinPageNotifier();
    }, builder: ((context, child) {
      this.context = context;
      return HiddenPinUI(state: this);
    }));
  }

  void showDialogImage(Pin pin) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
            title: const Text('Image'),
            content: pin.image.getWidget()
        )
    );
  }

  Future<void> unHidePin(Pin pin) async {
    await Provider.of<HiddenPinPageNotifier>(context, listen: false).unHidePin(pin);
    if (!mounted) return;
    Provider.of<ClusterNotifier>(context, listen: false).addPin(pin);
  }




}