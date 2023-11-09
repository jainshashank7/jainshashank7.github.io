import 'dart:async';
import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:debug_logger/debug_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mobex_kiosk/core/theme/dashboard_bloc/dashboard_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../enitity/user.dart';
import '../../../repositories/auth_repository.dart';
import '../../../utils/config/api_config.dart';
import '../../../utils/config/api_key.dart';
import '../app_bloc/app_bloc.dart';
import '../connectivity_bloc/connectivity_bloc.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  AuthBloc({
    required User me,
    required AppBloc appBloc,
    required ConnectivityBloc connectivityBloc,
    required DashboardBloc dashboardBloc,
  })  : _me = me,
        _appBloc = appBloc,
        _connectivityBloc = connectivityBloc,
        _dashboardBloc = dashboardBloc,
        super(AuthState.initial()) {
    on<SignInAuthEvent>(_onSignInAuthEvent);
    on<AutoSignInAuthEvent>(_onAutoSignInAuthEvent);
    on<StartedCompleteSignInAuthEvent>(_onStartedCompleteSignInAuthEvent);
    on<AuthenticatedEvent>(_onAuthenticatedEvent);
    on<ConfirmUserSignInAuthEvent>(_onConfirmUserSignInAuthEvent);
    on<SignOutAuthEvent>(_onSignOutAuthEvent);
    on<ResetConfirmUserFailedAuthEvent>(_onResetConfirmUserFailedAuthEvent);
    on<SuccessfullyAuthenticatedAuthEvent>(
      _onSuccessfullyAuthenticatedAuthEvent,
    );
    add(AutoSignInAuthEvent());
  }

  final User _me;
  final AuthRepository _authRepository = AuthRepository();
  final FlutterSecureStorage _vault = FlutterSecureStorage();
  var userEmail = "";

  ConnectivityBloc _connectivityBloc;

  final AppBloc _appBloc;

  final DashboardBloc _dashboardBloc;

  Future<void> _onSignInAuthEvent(SignInAuthEvent event, emit) async {
    final prefs = await SharedPreferences.getInstance();
    state.copyWith(status: AuthStatus.loading);
    print("reached");
    try {
      await _authRepository.signIn(
        username: event.username,
        password: event.password,
      );

      User current = await _authRepository.currentUser();

      if (current.id != null) {
        print("authenticate");
        DebugLogger.info(current.toMap());
        prefs.setBool('authenticate', false);
        _me.copyFrom(current);

        String jsonData = jsonEncode(current.toCurrentAuthUserJson());

        await _vault.write(key: "current_user", value: jsonData);

        await _vault.write(key: 'creds_username', value: event.username);
        await _vault.write(key: 'creds_pass_code', value: event.password);

        add(SuccessfullyAuthenticatedAuthEvent());
      } else {
        emit(state.copyWith(status: AuthStatus.confirmFailed));
      }
    } on UserNotFoundException {
      print("errror1");
      emit(state.copyWith(status: AuthStatus.confirmFailed));
    } catch (er) {
      print("errror");
      emit(state.copyWith(status: AuthStatus.confirmFailed));
    }
  }

  Future<void> _onAutoSignInAuthEvent(event, emit) async {
    try {
      _connectivityBloc.add(ListenToConnectivityStatus());
      _connectivityBloc.add(CheckInternetConnectivity());
      bool isSignedIn = await _authRepository.isSignedIn();

      String? _user = await _vault.read(key: 'creds_username') ?? '';
      String? _pass = await _vault.read(key: 'creds_pass_code') ?? '';

      if (isSignedIn) {
        add(SuccessfullyAuthenticatedAuthEvent());
      } else if (_user.isNotEmpty && _pass.isNotEmpty) {
        add(SignInAuthEvent(username: _user, password: _pass));
      } else {
        throw Exception("Unable to load user");
      }
    } catch (err) {
      add(StartedCompleteSignInAuthEvent());
    }
  }

  Future<void> _onConfirmUserSignInAuthEvent(
    ConfirmUserSignInAuthEvent event,
    emit,
  ) async {
    try {
      if (state.status == AuthStatus.confirmationRequired ||
          state.status == AuthStatus.unauthenticated ||
          state.status != AuthStatus.authenticated) {
        emit(state.copyWith(status: AuthStatus.confirming));
        add(SignInAuthEvent(
          username: event.email,
          password: event.inviteCode,
        ));
      }
    } catch (err) {
      DebugLogger.error(err);
      emit(state.copyWith(status: AuthStatus.confirmFailed));
      throw Exception('Unable to verify user at the moment');
    }
  }

  Future<void> _onStartedCompleteSignInAuthEvent(event, emit) async {
    emit(state.copyWith(status: AuthStatus.confirmationRequired));
  }

  Future<bool> _isConnectedToInternet() async {

    return kIsWeb ? true :  await ConnectivityWrapper.instance.isConnected;
  }

  Future<void> _onSuccessfullyAuthenticatedAuthEvent(event, emit) async {
    if (await _isConnectedToInternet()) {
      try {
        emit(state.copyWith(status: AuthStatus.loading));

        User _current = await _authRepository.currentUser();

        _me.copyFrom(_current);

        _appBloc.add(AppInitializedEvent());
        String? email = _me.email;
        String? accessToken = await _authRepository.generateAccessToken();
        String clientId = _me.customAttribute2.userId;
        String companyId = _me.customAttribute2.companyId;

        if (accessToken != null) {
          String memberProfile =
              '${ApiConfig.baseUrl}/integrations/clients/client-profile-photo';

          var headers = {
            "x-api-key": ApiKey.webManagementConsoleApi,
            "Authorization": accessToken,
            "x-client-id": clientId,
            "x-company-id": companyId,
          };

          var response =
              await http.get(Uri.parse(memberProfile), headers: headers);

          DebugLogger.info(response.body);
          if (response.statusCode == 200) {
            try {
              Map<String, dynamic> data = json.decode(response.body);

              String url = data['profilePhotoUrl'];
              print("image of user iss " + url);
              emit(state.copyWith(
                  user: _me.copyWith(profileUrl: url),
                  status: AuthStatus.authenticated));
            } catch (err) {
              DebugLogger.error(err);
              emit(state.copyWith(user: _me, status: AuthStatus.authenticated));
            }
          } else
            emit(state.copyWith(user: _me, status: AuthStatus.authenticated));
        } else
          emit(state.copyWith(status: AuthStatus.unauthenticated));
      } catch (err) {
        print("Inside CAtch Block");
        DebugLogger.error(err);
        _me.copyFrom(state.user);
        _appBloc.add(AppInitializedOfflineEvent());

        emit(state.copyWith(status: AuthStatus.authenticated));
      }
    } else {
      //offline
      try {
        emit(state.copyWith(status: AuthStatus.loading));

        _appBloc.add(AppInitializedEvent());
        emit(state.copyWith(status: AuthStatus.authenticated));
      } catch (err) {
        DebugLogger.error(err);
        _me.copyFrom(state.user);
        _appBloc.add(AppInitializedOfflineEvent());

        emit(state.copyWith(status: AuthStatus.authenticated));
      }
    }
  }

  Future<void> _onSignOutAuthEvent(SignOutAuthEvent event, emit) async {
    try {
      await _authRepository.signeOut();
      _dashboardBloc.add(ResetDashboardState());
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    } catch (err) {
      DebugLogger.error(err);
      emit(state.copyWith(status: AuthStatus.authenticated));
    }
  }

  Future<void> _onResetConfirmUserFailedAuthEvent(
    ResetConfirmUserFailedAuthEvent event,
    emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.confirmationRequired));
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    return AuthState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    return state.toJson();
  }

  FutureOr<void> _onAuthenticatedEvent(
      AuthenticatedEvent event, Emitter<AuthState> emit) {
    emit(state.copyWith(status: AuthStatus.authenticated));
  }
}
