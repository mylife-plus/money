import 'package:flutter/material.dart';

class SlideFromTopRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideFromTopRoute({required this.page, super.settings})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, -1.0);
          const end = Offset.zero;
          const curve = Curves.easeOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        barrierColor: Colors
            .black54, // Optional: dim background if desired, but for full page usually not needed unless modal like.
        // For full screen pages sticking to default opaque true implicitly via PageRouteBuilder defaults usually
        opaque: true,
      );
}
