import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:mobex_kiosk/utils/helpers/amplify_helper.dart';
import 'package:provider/provider.dart';

import 'core/blocs/app_bloc/app_bloc.dart';
import 'core/blocs/auth_bloc/auth_bloc.dart';
import 'core/blocs/connectivity_bloc/connectivity_bloc.dart';
import 'core/blocs/digital_signage_bloc/digital_signage_bloc.dart';
import 'core/screens/screen_distributor.dart';
import 'core/screens/widgets/navigation_provider.dart';
import 'core/theme/dashboard_bloc/dashboard_bloc.dart';
import 'core/theme/theme_builder_bloc/theme_builder_bloc.dart';
import 'enitity/user.dart';

class KioskApp extends StatelessWidget {
  const KioskApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("INside KioskAPP");
    return ChangeNotifierProvider(
        create: (context) => NavigationProvider(),
        child: Provider(
          lazy: false,
          create: (context) => User(),
          child: BlocProvider.value(
            value: connectivityBloc,
            child: MultiBlocProvider(
              providers: [
                BlocProvider<DigitalSignageBloc>(
                  lazy: false,
                  create: (context) => DigitalSignageBloc(me: Provider.of<User>(context,listen:false)),
                ),
                BlocProvider<DashboardBloc>(
                  lazy: false,
                  create: (context) => DashboardBloc(
                    me: Provider.of<User>(context, listen: false),
                  ),
                ),
                BlocProvider<AppBloc>(
                  lazy: false,
                  create: (context) => AppBloc(
                    me: Provider.of<User>(context, listen: false),
                  ),
                ),
                BlocProvider(
                  lazy: false,
                  create: (BuildContext context) => AuthBloc(
                    me: Provider.of<User>(context, listen: false),
                    appBloc: BlocProvider.of<AppBloc>(context),
                    connectivityBloc:
                        BlocProvider.of<ConnectivityBloc>(context),
                    dashboardBloc: BlocProvider.of<DashboardBloc>(context),
                  ),
                ),
                BlocProvider<ThemeBuilderBloc>(
                  lazy: false,
                  create: (BuildContext context) => ThemeBuilderBloc(
                    me: Provider.of<User>(context, listen: false),
                    digitalSignageBloc:
                        BlocProvider.of<DigitalSignageBloc>(context),
                  ),
                ),
              ],
              child: ScreenUtilInit(
                designSize: Size(1920, 1080),
                minTextAdapt: true,
                splitScreenMode: true,
                builder: (context, child) {
                  return _KioskAppBlocInjector();
                },
                child: _KioskAppBlocInjector(),
              ),
            ),
          ),
        ));
  }
}

class _KioskAppBlocInjector extends StatefulWidget {
  const _KioskAppBlocInjector({
    Key? key,
  }) : super(key: key);

  @override
  State<_KioskAppBlocInjector> createState() => _KioskAppBlocInjectorState();
}

class _KioskAppBlocInjectorState extends State<_KioskAppBlocInjector> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InAppNotification(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: ScreenDistributor(),
        ),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
      ),
    );
  }
}
