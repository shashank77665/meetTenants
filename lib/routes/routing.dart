import 'package:flutter/material.dart';
import 'package:meettenants/auth/presentation/login.dart';
import 'package:meettenants/auth/presentation/signup.dart';
import 'package:meettenants/broker/presentation/brokerhome.dart';
import 'package:meettenants/eua/presentation/auahome.dart';

Map<String, Widget Function(BuildContext)> routeList = <String, WidgetBuilder>{
  '/login': (context) => LoginScreen(),
  '/signup': (context) => SignupScreen(),
  '/EUAHome': (context) => EUAHome(),
  '/brokerHome': (context) => BrokerHomeScreen()
};
