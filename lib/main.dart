import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mobex_kiosk/kiosk_app.dart';
import 'package:mobex_kiosk/utils/config/locale.dart';
import 'package:mobex_kiosk/utils/helpers/amplify_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart';
import 'package:video_player_win/video_player_win_plugin.dart';
import 'package:window_manager/window_manager.dart';

import 'core/blocs/bloc_observer.dart';
import 'core/screens/widgets/custom_screen_util.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && Platform.isWindows) {
    WindowsVideoPlayer.registerWith();
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      // size: Size(1440, 2500),
      // center: true,
      // backgroundColor: Colors.blue,
      fullScreen: true,
      // skipTaskbar: false,
      // titleBarStyle: TitleBarStyle.normal,
      // windowButtonVisibility: false,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: kIsWeb
          ? HydratedStorage.webStorageDirectory
          : await getTemporaryDirectory(),
    );
    await EasyLocalization.ensureInitialized();

    await FCAmplify.initialize();

    initializeTimeZones();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (!kIsWeb && Platform.isAndroid) {
      await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

      var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
          AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
      var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
          AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

      if (swAvailable && swInterceptAvailable) {
        AndroidServiceWorkerController serviceWorkerController =
        AndroidServiceWorkerController.instance();

        await serviceWorkerController.setServiceWorkerClient(
          AndroidServiceWorkerClient(
            shouldInterceptRequest: (request) async {
              print(request);
              return null;
            },
          ),
        );
      }
    }


    CustomScreenUtil.init();

    runApp(
      EasyLocalization(
          path: 'assets/langs',
          supportedLocales: supportedLocales,
          fallbackLocale: supportedLocales.first,
          saveLocale: true,
          child: KioskApp()),
    );
  }

