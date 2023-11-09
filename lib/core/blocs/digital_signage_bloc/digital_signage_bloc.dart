// import 'dart:async';

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:debug_logger/debug_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wakelock/wakelock.dart';
import '../../../enitity/user.dart';
import '../../../repositories/auth_repository.dart';
import '../../../utils/config/api_config.dart';
import '../../../utils/config/api_key.dart';
import 'digital_signage_event.dart';
import 'digital_signage_state.dart';

class DigitalSignageBloc
    extends Bloc<DigitalSignageEvent, DigitalSignageState> {
  DigitalSignageBloc({required User me})
      : _me = me,
        super(DigitalSignageState.initial()) {
    on<EnableScreenSaverTimer>(_startTimerScreenSaver);
    on<ResetScreenSaverTimer>(_resetScreenSaver);
    on<ShowScreenSaver>(showScreenSaver);
    on<AddDigitalSignageData>(addDigitalSignageData);
    on<StopScreenSaverTimer>(_stopScreenSaverTimer);
  }

  final User _me;
  final AuthRepository _authRepository = AuthRepository();
  late Timer _timer;
  bool _showScreenSaver = false;

  void addDigitalSignageData(AddDigitalSignageData event, emit) async {
    DebugLogger.info("Inside AddDigitalSignageData");

    String? accessToken = await _authRepository.generateAccessToken();
    String clientId = _me.customAttribute2.userId;
    String companyId = _me.customAttribute2.companyId;

    if (await _isConnectedToInternet() && accessToken != null) {
      var headers = {
        "x-api-key": ApiKey.webManagementConsoleApi,
        "Authorization": accessToken,
        "x-client-id": clientId,
        "x-company-id": companyId,
        "Content-Type": "application/json"
      };

      var clientBody = json.encode({
        "ids": [clientId]
      });

      try {
        var clientResponse = await http.post(
            Uri.parse(
                '${ApiConfig.baseUrl}/integrations/clients/clients-by-ids'),
            body: clientBody,
            headers: headers);

        var responseT = await http.get(
            Uri.parse(
                '${ApiConfig.baseUrl}/integrations/dashboard-builder/template/${json.decode(clientResponse.body)[0]["dashboard_used"]}'),
            headers: headers);

        if (responseT.statusCode == 200 || responseT.statusCode == 201) {
          var responseData =
              json.decode(responseT.body)["templateMeta"]["data"];
          var responseTheme = json.decode(responseData);
          // var digitalSignageData = responseTheme["page3"]["digitalSignage"];
          var imageDuration = responseTheme["page3"]["timeText"];
          var screenTimeout = responseTheme["page3"]["timeoutText"];
          var digitalSignageDataList = responseTheme["page3"]["digitalSignage"];
          List<dynamic> imagesUrls =
              digitalSignageDataList.map((digitalSignageImageObject) {
            return digitalSignageImageObject['image'];
          }).toList();
          DebugLogger.info("ImageURLS");
          DebugLogger.info(imagesUrls);
          DebugLogger.info(imageDuration);
          DebugLogger.info(screenTimeout);
          emit(state.copyWith(
              showScreenSaver: false,
              imagesUrls: imagesUrls,
              imageDuration: imageDuration,
              screenTimeout: screenTimeout,
              stateUpdate: state.stateUpdate + 1));
          add(EnableScreenSaverTimer());
        }
      } catch (error) {
        DebugLogger.error(error);
      }
    }
  }

  Future<void> _startTimerScreenSaver(EnableScreenSaverTimer event, emit) async {
    emit(state.copyWith(showScreenSaver: false));
    // add(AddDigitalSignageData());
    DebugLogger.info("STATE DATA ::: ${state.toString()}");
    DebugLogger.info("Start Timer");
    DebugLogger.info("Wakelock enabled");
    await Wakelock.enable();
    _timer = Timer(Duration(seconds: state.screenTimeout), () async {
      _showScreenSaver = true;
      add(ShowScreenSaver());
      DebugLogger.info("Show Screen Saver");
    });
    DebugLogger.info(_showScreenSaver);
    // emit(state.copyWith(showScreenSaver: _showScreenSaver));
    DebugLogger.info("Emitted State");
  }

  Future<void> _resetScreenSaver(ResetScreenSaverTimer event, emit) async {
    DebugLogger.info("End Timer");
    _timer.cancel();
    if (await Wakelock.enabled) {
      DebugLogger.info("Disabling Wakelock");
      await Wakelock.disable();
    }
    _showScreenSaver = false;
    DebugLogger.info("Logout State :: ${event.logout}");
    emit(state.copyWith(showScreenSaver: _showScreenSaver));
    if (!event.logout) {
      DebugLogger.info("Inside ResetScreenSaver");
      add(EnableScreenSaverTimer());
    }
  }

  void _stopScreenSaverTimer(StopScreenSaverTimer event, emit) {
    DebugLogger.info("Inside _stopScreenSaverTimer");
    if (_timer.isActive) {
      DebugLogger.info("Timer Stopped");
      _timer.cancel();
    }
  }

  void showScreenSaver(ShowScreenSaver event, emit) {
    _showScreenSaver = true;
    emit(state.copyWith(showScreenSaver: _showScreenSaver));
    DebugLogger.info("State ${state.showScreensaver}");
  }

  Future<bool> _isConnectedToInternet() async {
    return kIsWeb ? true : await ConnectivityWrapper.instance.isConnected;
  }
}
