import 'package:flutter/cupertino.dart';

class Routing {

  static dynamic to(BuildContext context, Widget to, [bool transition = true]) async {
     return await Navigator.of(context).push(
         PageRouteBuilder(
           pageBuilder: (context, animation, secondaryAnimation) => to,
           transitionsBuilder: (context, animation, secondaryAnimation, child) {
             const begin = Offset(1.0, 0.0);
             const end = Offset.zero;
             const curve = Curves.ease;
             var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
             return SlideTransition(
               position: animation.drive(tween),
               child: child,
             );
           },
         )
     );
  }
}