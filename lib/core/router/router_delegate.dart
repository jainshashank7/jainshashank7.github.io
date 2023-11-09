import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobex_kiosk/core/screens/signin_screen.dart';


part 'router_delegate.gr.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Screen,Route',
  routes: <AutoRoute>[
    AutoRoute(page: SignInScreen, initial: true),
  ],
)
class FCRouter extends _$FCRouter {}

final FCRouter fcRouter = FCRouter();
/*
 * Page name should contain 'Screen' at the end.
 * 'Screen' will replace with 'Route'.
 * Code generation need to run in order to effect the changes
 * TODO: You can run :-
           'flutter packages pub run build_runner build --delete-conflicting-outputs'  each time you edit this file
            OR
            'flutter packages pub run build_runner watch --delete-conflicting-outputs' to watch code changes and regenerate
*/
