import 'package:flutter/material.dart';

class SlidePageRoute extends PageRouteBuilder {
  final WidgetBuilder builder;
  final Offset direction;
  final Curve curve;
  
  SlidePageRoute({required this.builder, this.direction = const Offset(1, 0), this.curve = Curves.easeIn}) : super(
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final animatableTween = Tween(begin: direction, end: Offset.zero).chain(CurveTween(curve: curve));
      
      return SlideTransition(position: animation.drive(animatableTween), child: child,);
    }
  );
}