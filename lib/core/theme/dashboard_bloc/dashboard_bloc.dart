import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:debug_logger/debug_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobex_kiosk/utils/barrel.dart';

import '../../../enitity/user.dart';
import '../../../repositories/auth_repository.dart';
import '../../../utils/config/api_config.dart';
import '../../../utils/config/api_key.dart';
import '../entity/main_module_info.dart';
import '../entity/main_module_item.dart';
import '../entity/sub_module_info.dart';
import '../entity/sub_module_item.dart';
import '../entity/sub_module_link.dart';

part 'dashboard_event.dart';

part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({
    required User me,
  })  : _me = me,
        super(DashboardState.initial()) {
    on<FetchMainModuleDetailsEvent>(_onFetchMainModuleDetailsEvent);
    on<FetchMainModuleInfoEvent>(_onFetchMainModuleInfoEvent);
    on<FetchSubModuleDetailsEvent>(_onFetchSubModuleDetailsEvent);
    on<FetchSubModuleInfoEvent>(_onFetchSubModuleInfoEvent);
    on<FetchSubModuleLinksEvent>(_onFetchSubModuleLinksEvent);
    on<FetchSubModuleLinksInfoEvent>(_onFetchSubModuleLinksInfoEvent);
    on<ResetDashboardState>(_onResetDashboardState);
  }

  final User _me;
  final AuthRepository _authRepository = AuthRepository();

  Future<FutureOr<void>> _onFetchMainModuleDetailsEvent(
      FetchMainModuleDetailsEvent event, Emitter<DashboardState> emit) async {
    String? accessToken = await _authRepository.generateAccessToken();
    String clientId = _me.customAttribute2.userId;
    String companyId = _me.customAttribute2.companyId;

    List<MainModuleItem> mainModuleItems = [];

    if (await isConnectedToInternet() && accessToken != null) {
      var headers = {
        "x-api-key": ApiKey.webManagementConsoleApi,
        "Authorization": accessToken,
        "x-client-id": clientId,
        "x-company-id": companyId,
        "Content-Type": "application/json"
      };

      var imageBody1 = json.encode({
        "ids": [clientId]
      });
      var clientResponse = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/integrations/clients/clients-by-ids'),
          body: imageBody1,
          headers: headers);

      print("hi dashboard used " +
          clientId +
          json.decode(clientResponse.body).toString());
      var dashboardUsed = json.decode(clientResponse.body)[0]["dashboard_used"];

      String baseUrlWebLinks =
          '${ApiConfig.baseUrl}/integrations/generic-modules/modulelist/Web Link/kiosk/${dashboardUsed}';
      String baseUrlPDF =
          '${ApiConfig.baseUrl}/integrations/generic-modules/modulelist/PDF Link/kiosk/${dashboardUsed}';
      String baseUrlVideo =
          '${ApiConfig.baseUrl}/integrations/generic-modules/modulelist/Video Link/kiosk/${dashboardUsed}';
      String baseUrlDashboardPage =
          '${ApiConfig.baseUrl}/integrations/generic-modules/modulelist/Dashboard Page/kiosk/${dashboardUsed}';

      var responseT = await http.get(
          Uri.parse(
              '${ApiConfig.baseUrl}/integrations/dashboard-builder/template/${dashboardUsed}'),
          headers: headers);


      var response1 =
          await http.get(Uri.parse(baseUrlWebLinks), headers: headers);
      var response2 = await http.get(Uri.parse(baseUrlPDF), headers: headers);
      var response3 = await http.get(Uri.parse(baseUrlVideo), headers: headers);
      var response4 =
          await http.get(Uri.parse(baseUrlDashboardPage), headers: headers);

      print("sts code :: ${response1.statusCode}");
      print(response1.body);
      print(response2.body);
      print(response3.body);
      print(response4.body);

      if (responseT.statusCode == 200 || responseT.statusCode == 201) {
        var responseData = json.decode(responseT.body)["templateMeta"]["data"];
        var responseTheme = json.decode(responseData);
        Map<String, dynamic> moduleList =
        responseTheme["page4"]["template"]["LI"];

        print("page4 data11");
        DebugLogger.info(moduleList);
        // DebugLogger.error(moduleList["template"]["LI"]);

        // List<MainModuleItem> thirdPartyApps = ;
        moduleList.entries.forEach(
              (element) {
            var key = element.key;
            var name = key.split(" ");
            print(name);
            List<dynamic> res = element.value["elements"];
            if (res.isNotEmpty && res[0]["function_type"] == "3rdParty") {
              MainModuleItem mainModuleItem = MainModuleItem(
                  id: res[0]["id"],
                  title: res[0]["function_name"],
                  image: res[0]["image"],
                  url: "",
                  imageUrl: res[0]["image"],
                  type: res[0]["function_type"],
                  color: ColorPallet.kPrimary,
                  position: int.parse(name[1]),
                  textColor: ColorPallet.kSecondary,
                  androidId: res[0]["android_id"],
                  iosId: res[0]["ios_id"],
                  windowsId: res[0]["windows_id"]);
              print(
                element.value["elements"][0]["function_type"],
              );

              mainModuleItems.add(mainModuleItem);
            }
          },
        );
      }

      if (response1.statusCode == 200) {


        List<MainModuleItem> webLinks =
            MainModuleItem.fromJsonList(jsonDecode(response1.body), "weblink");
        List<MainModuleItem> pdfs =
            MainModuleItem.fromJsonList(jsonDecode(response2.body), "pdf");
        List<MainModuleItem> videos =
            MainModuleItem.fromJsonList(jsonDecode(response3.body), "video");
        List<MainModuleItem> modules =
            MainModuleItem.fromJsonList(jsonDecode(response4.body), "module");

        mainModuleItems.addAll(webLinks);
        mainModuleItems.addAll(pdfs);
        mainModuleItems.addAll(videos);
        mainModuleItems.addAll(modules);

        // for (var i in mainModuleItems) {
        //   print(i.toJson());
        // }

        List<MainModuleItem> updatedMainModuleItems =
            List.generate(12, (index) {
          var existingItem = mainModuleItems.firstWhere(
            (item) => item.position - 1 == index,
            orElse: () => MainModuleItem(
              id: index,
              title: "empty-we-made-it",
              image: '',
              url: '',
              imageUrl: '',
              type: '',
              color: Colors.red,
              position: index,
              textColor: Colors.red,
              androidId: "",
              iosId: "",
              windowsId: "",
            ),
          );

          return existingItem;
        });

        updatedMainModuleItems.sort((a, b) => a.position.compareTo(b.position));

        print('%%%%%%%%%%%');
        for (int i = 0; i < 12; i++) {
          print(updatedMainModuleItems[i].toJson());
        }

        emit(state.copyWith(mainModuleItems: updatedMainModuleItems));
      }
    }
  }

  Future<FutureOr<void>> _onFetchSubModuleDetailsEvent(
      FetchSubModuleDetailsEvent event, Emitter<DashboardState> emit) async {
    String? accessToken = await _authRepository.generateAccessToken();
    String clientId = _me.customAttribute2.userId;
    String companyId = _me.customAttribute2.companyId;

    if (await isConnectedToInternet() && accessToken != null) {
      String baseURL =
          '${ApiConfig.baseUrl}/integrations/generic-modules/submodulelist/${event.id}';

      var headers = {
        "x-api-key": ApiKey.webManagementConsoleApi,
        "Authorization": accessToken,
        "x-client-id": clientId,
        "x-company-id": companyId,
      };

      var response = await http.get(Uri.parse(baseURL), headers: headers);

      if (response.statusCode == 200) {
        List<SubModuleItem> subModules =
            SubModuleItem.fromJsonList(jsonDecode(response.body));

        for (var item in subModules) {
          if (item.url == '') {
            add(FetchSubModuleLinksEvent(id: item.id));
          }
        }

        emit(state.copyWith(subModuleItems: subModules));
      }
    }
  }

  Future<FutureOr<void>> _onFetchMainModuleInfoEvent(
      FetchMainModuleInfoEvent event, Emitter<DashboardState> emit) async {
    String? accessToken = await _authRepository.generateAccessToken();
    String clientId = _me.customAttribute2.userId;
    String companyId = _me.customAttribute2.companyId;

    if (await isConnectedToInternet() && accessToken != null) {
      String baseURL =
          '${ApiConfig.baseUrl}/integrations/generic-modules/module/1';

      var headers = {
        "x-api-key": ApiKey.webManagementConsoleApi,
        "Authorization": accessToken,
        "x-client-id": clientId,
        "x-company-id": companyId,
      };

      var response = await http.get(Uri.parse(baseURL), headers: headers);

      print(response.body);

      if (response.statusCode == 200) {
        MainModuleInfo mainModuleInfo =
            MainModuleInfo.fromJson(jsonDecode(response.body));

        emit(state.copyWith(mainModuleInfo: mainModuleInfo));
      }
    }
  }

  Future<FutureOr<void>> _onFetchSubModuleInfoEvent(
      FetchSubModuleInfoEvent event, Emitter<DashboardState> emit) async {
    String? accessToken = await _authRepository.generateAccessToken();
    String clientId = _me.customAttribute2.userId;
    String companyId = _me.customAttribute2.companyId;

    if (await isConnectedToInternet() && accessToken != null) {
      String baseURL =
          '${ApiConfig.baseUrl}/integrations/generic-modules/submodule/1';

      var headers = {
        "x-api-key": ApiKey.webManagementConsoleApi,
        "Authorization": accessToken,
        "x-client-id": clientId,
        "x-company-id": companyId,
      };

      var response = await http.get(Uri.parse(baseURL), headers: headers);

      print(response);

      if (response.statusCode == 200) {
        SubModuleInfo subModuleInfo =
            SubModuleInfo.fromJson(jsonDecode(response.body));

        emit(state.copyWith(subModuleInfo: subModuleInfo));
      }
    }
  }

  Future<FutureOr<void>> _onFetchSubModuleLinksEvent(
      FetchSubModuleLinksEvent event, Emitter<DashboardState> emit) async {
    String? accessToken = await _authRepository.generateAccessToken();
    String clientId = _me.customAttribute2.userId;
    String companyId = _me.customAttribute2.companyId;

    if (await isConnectedToInternet() && accessToken != null) {
      String baseURL =
          '${ApiConfig.baseUrl}/integrations/generic-modules/submodulelinkslist/${event.id}';

      var headers = {
        "x-api-key": ApiKey.webManagementConsoleApi,
        "Authorization": accessToken,
        "x-client-id": clientId,
        "x-company-id": companyId,
      };

      var response = await http.get(Uri.parse(baseURL), headers: headers);

      if (response.statusCode == 200) {
        List<SubModuleLink> list =
            SubModuleLink.fromJsonList(jsonDecode(response.body));

        Map<int, List<SubModuleLink>> old = state.subModuleLinks;
        old[event.id] = list;

        emit(state.copyWith(subModuleLinks: old));
      }
      print(state.subModuleLinks);
    }
  }

  Future<FutureOr<void>> _onFetchSubModuleLinksInfoEvent(
      FetchSubModuleLinksInfoEvent event, Emitter<DashboardState> emit) async {
    String? accessToken = await _authRepository.generateAccessToken();
    String clientId = _me.customAttribute2.userId;
    String companyId = _me.customAttribute2.companyId;

    if (await isConnectedToInternet() && accessToken != null) {
      String baseURL =
          '${ApiConfig.baseUrl}/integrations/generic-modules/submodulelinks/:id';

      var headers = {
        "x-api-key": ApiKey.webManagementConsoleApi,
        "Authorization": accessToken,
        "x-client-id": clientId,
        "x-company-id": companyId,
      };

      var response = await http.get(Uri.parse(baseURL), headers: headers);
    }
  }

  Future<bool> isConnectedToInternet() async {
    if(!kIsWeb){
    return await ConnectivityWrapper.instance.isConnected;}
    return true;
  }

  FutureOr<void> _onResetDashboardState(
      ResetDashboardState event, Emitter<DashboardState> emit) {
    emit(state.copyWith(
      mainModuleItems: [],
    ));
  }
}
