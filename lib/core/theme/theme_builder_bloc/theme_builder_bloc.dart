import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:debug_logger/debug_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobex_kiosk/core/blocs/digital_signage_bloc/digital_signage_event.dart';

import '../../../enitity/user.dart';
import '../../../repositories/auth_repository.dart';
import '../../../utils/config/api_config.dart';
import '../../../utils/config/api_key.dart';
import '../../../utils/config/color_pallet.dart';
import '../../blocs/digital_signage_bloc/digital_signage_bloc.dart';

part 'theme_builder_event.dart';

part 'theme_builder_state.dart';

class ThemeBuilderBloc extends Bloc<ThemeBuilderEvent, ThemeBuilderState> {
  ThemeBuilderBloc(
      {required User me, required DigitalSignageBloc digitalSignageBloc})
      : _me = me,
        _digitalSignageBloc = digitalSignageBloc,
        super(ThemeBuilderState.initial()) {
    on<FetchDetailsEvent>(_onFetchMemberProfileDetailsEvent);
  }

  final User _me;
  final AuthRepository _authRepository = AuthRepository();
  final DigitalSignageBloc _digitalSignageBloc;

  FutureOr<void> _onFetchMemberProfileDetailsEvent(
      FetchDetailsEvent event, Emitter<ThemeBuilderState> emit) async {
    String? email = _me.email;
    String? accessToken = await _authRepository.generateAccessToken();
    String clientId = _me.customAttribute2.userId;
    String companyId = _me.customAttribute2.companyId;

    print("Token :: $accessToken");
    print("Inside Theme Builder Bloc");
    if (accessToken != null) {
      var headers = {
        "x-api-key": ApiKey.webManagementConsoleApi,
        "Authorization": accessToken,
        "x-client-id": clientId,
        "x-company-id": companyId,
        "Content-Type": "application/json"
      };
      print("X-aPI-key ::: ${ApiKey.webManagementConsoleApi}");
      print(accessToken);

      print("Client ID ::: $clientId");
      print("Company ID ::: $companyId");

      var imageBody1 = json.encode({
        "ids": [clientId]
      });

      print(Uri.parse(
          '${ApiConfig.baseUrl}/integrations/clients/clients-by-ids'));

      try {
        var clientResponse = await http.post(
            Uri.parse(
                '${ApiConfig.baseUrl}/integrations/clients/clients-by-ids'),
            body: imageBody1,
            headers: headers);
        DebugLogger.info(clientResponse.body);
        print(json.decode(clientResponse.body)[0]["dashboard_used"]);
        var responseT = await http.get(
            Uri.parse(
                '${ApiConfig.baseUrl}/integrations/dashboard-builder/template/${json.decode(clientResponse.body)[0]["dashboard_used"]}'),
            headers: headers);

        print('rsp bg');
        DebugLogger.info(responseT.body.toString());
        if (responseT.statusCode == 200 || responseT.statusCode == 201) {
          var responseData =
              json.decode(responseT.body)["templateMeta"]["data"];
          var responseTheme = json.decode(responseData);
          var logoData = responseTheme["page3"]["logo"]["fileId"];
          var backgroundData = responseTheme["page3"]["background"]["file_id"];

          // var digitalSignageData = responseTheme["page3"]["digitalSignage"];
          // var imageDuration = responseTheme["page3"]["timeText"];
          // _digitalSignageBloc.add(AddDigitalSignageData(
          //   digitalSignageData: digitalSignageData,
          //   screenTimeout: 30,
          //   imageDuration: int.parse(imageDuration),
          // ));

          var imageBody = json.encode({
            "fileIds": [logoData, backgroundData]
          });

          DebugLogger.info(responseTheme["page3"]);

          try {
            var responseImages = await http.post(
                Uri.parse(
                    '${ApiConfig.baseUrl}/integrations/dashboard-builder/get-urls'),
                body: imageBody,
                headers: headers);

            var reponseImageData = json.decode(responseImages.body);
            if (responseImages.statusCode == 200 ||
                responseImages.statusCode == 200) {
              responseTheme["page3"]["logo"]["image"] =
                  reponseImageData["data"][0]["image"];
              responseTheme["page3"]["background"]["image"] =
                  reponseImageData["data"][1]["image"];
            } else {
              responseTheme["page3"]["logo"]["image"] = "";
              responseTheme["page3"]["background"]["image"] = "";
            }

            DebugLogger.info(reponseImageData["data"][1]);
          } catch (e) {
            print(e);
            responseTheme["page3"]["logo"]["image"] = "";
            responseTheme["page3"]["background"]["image"] = "";
          }
          ThemeBuilderState current =
              ThemeBuilderState.fromJson((responseTheme));

          // // final DatabaseHelperForUsers db = DatabaseHelperForUsers();
          ColorPallet.setKSecondary = current.themeData.colors.secondary;
          ColorPallet.setKPrimary = current.themeData.colors.primary;
          ColorPallet.setKTertiary = current.themeData.colors.tertiary;
          emit(state.copyWith(
              functionList: current.themeData,
              coreApps: current.dashboardBuilder));
        } else {}
      } catch (e) {
        print(e);
      }
    }
  }

  Future<bool> _isConnectedToInternet() async {
    if(!kIsWeb){
    return await ConnectivityWrapper.instance.isConnected;}
    return true;
  }
}
