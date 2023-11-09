import 'dart:async';

import 'package:animations/animations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobex_kiosk/core/screens/signin_screen.dart';

import '../../utils/config/color_pallet.dart';
import '../blocs/app_bloc/app_bloc.dart';
import '../blocs/auth_bloc/auth_bloc.dart';
import '../router/router_delegate.dart';

class ScreenDistributor extends StatefulWidget {
  const ScreenDistributor({Key? key}) : super(key: key);

  @override
  State<ScreenDistributor> createState() => _ScreenDistributorState();
}

class _ScreenDistributorState extends State<ScreenDistributor>
    with WidgetsBindingObserver {
  late Timer onlineOfflineRecallTimer;
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: ColorPallet.kBackground,
        statusBarColor: ColorPallet.kBackground,
      ),
    );
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      if (onlineOfflineRecallTimer.isActive) {
        onlineOfflineRecallTimer.cancel();
      }
    } else if (state == AppLifecycleState.inactive) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      if (onlineOfflineRecallTimer.isActive ||
          state == AppLifecycleState.paused) {
        onlineOfflineRecallTimer.cancel();
      }
    } else if (state == AppLifecycleState.detached) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    }
  }

  @override
  void dispose() {
    onlineOfflineRecallTimer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, AuthState authState) {
        return Theme(
          data: ThemeData(fontFamily: GoogleFonts.roboto().fontFamily),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: ColorPallet.kBackground,
            body: Stack(
              children: [
                MaterialApp.router(
                  routerDelegate: fcRouter.delegate(),
                  routeInformationParser: fcRouter.defaultRouteParser(),
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  builder: (context, child) {
                    return MediaQuery(
                      child: child!,
                      data:
                          MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    );
                  },
                ),
                BlocBuilder<AppBloc, AppState>(
                  buildWhen: (prv, curr) => prv.locked != curr.locked,
                  builder: (context, state) {
                    return AnimatedSwitcher(
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                      ) {
                        return FadeScaleTransition(
                          animation: animation,
                          child: child,
                        );
                      },
                      duration: Duration(milliseconds: 300),
                      child: state.locked ? UnlockVerifiedUser(refreshData: true,) : SizedBox.shrink(),
                    );
                  },
                ),
                // BlocBuilder<MaintenanceBloc, MaintenanceState>(
                //   builder: (context, appConfig) {
                //     if (appConfig.config.maintenance) {
                //       return const MaintenanceScreen();
                //     }
                //     if (appConfig.config.forceUpdate) {
                //       return const ForceUpdateScreen();
                //     }
                //     return const SizedBox.shrink();
                //   },
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
