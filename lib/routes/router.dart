import 'package:IITDAPP/modules/attendance/attendance.dart';
import 'package:IITDAPP/modules/dashboard/dashboard.dart';
import 'package:IITDAPP/modules/explore/explore.dart';
import 'package:IITDAPP/routes/Routes.dart';
import 'package:flutter/material.dart';

class Router {

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.dashboard:
        return _createRoute(Dashboard());
      case Routes.attendance:
        return _createRoute(Attendance());
      case Routes.explore:
        return _createRoute(Explore());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                  child: Text('No route defined for ${settings.name}')),
            ));
    }
  }

  static Route _createRoute(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return FadeTransition(
//          position: animation.drive(tween),
          opacity: animation,//animation.drive(tween),
          child: child,
        );
      },
    );
  }
}