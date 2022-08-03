import 'package:buff_lisa/Files/io.dart';
import 'package:flutter/material.dart';
import 'camera.dart';

class AddPinScreen extends StatelessWidget {
  const AddPinScreen({super.key, required this.io});

  final IO io;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Screen'),
      ),
      body: Align(
        alignment: Alignment.topRight,
        child: CameraStatefulWidget(io: io),
      )
    );
  }
}