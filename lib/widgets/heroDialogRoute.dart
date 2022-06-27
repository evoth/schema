import 'package:flutter/material.dart';

/*
  Workaround by Collin Jackson (https://github.com/collinjackson) from
  https://github.com/flutter/flutter/issues/10667
*/

class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute({required this.builder, required this.duration}) : super();

  final WidgetBuilder builder;

  // Duration of hero animation
  final int duration;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: duration);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return new FadeTransition(
        opacity: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child);
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }
}
