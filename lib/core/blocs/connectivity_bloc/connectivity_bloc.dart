import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:debug_logger/debug_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:meta/meta.dart';


part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc() : super(ConnectivityState.initial()) {
    on<ListenToConnectivityStatus>(_onListenToConnectivityStatus);
    on<UpdateWifiStatus>(_onUpdateWifiStatus);
    on<UpdateInternetStatus>(_onUpdateInternetStatus);
    on<UpdateConnectionStatus>(_onUpdateConnectionStatus);
    on<UpdateBluetoothStatus>(_onUpdateBluetoothStatus);
    on<CheckInternetConnectivity>(_onCheckInternetConnectivity);
    add(ListenToConnectivityStatus());
  }

  StreamSubscription? _connectivity;
  StreamSubscription? _bluetooth;

  OverlayEntry? _offlineSnack;

  OverlayEntry? _onlineSnack;

  bool isInitial = true;

  Future<void> _onListenToConnectivityStatus(
    ListenToConnectivityStatus event,
    emit,
  ) async {
    _connectivity ??=
        Connectivity().onConnectivityChanged.listen((status) async {
      add(UpdateWifiStatus(status == ConnectivityResult.wifi));
      bool hasInternet = kIsWeb ? true : await ConnectivityWrapper.instance.isConnected;
      add(UpdateInternetStatus(hasInternet));
      add(UpdateConnectionStatus(status));

      if (!isInitial && hasInternet) {
        DebugLogger.info(
          "Your network connection restored.",
        );
      } else if (!hasInternet) {
        DebugLogger.error(
          "No internet, Please check you network connection.",
        );
      }
    });
    isInitial = false;

    // _bluetooth = FlutterReactiveBle().statusStream.listen((status) {
    //   add(UpdateBluetoothStatus(status == BleStatus.ready));
    // });
  }

  Future<void> _onUpdateWifiStatus(
    UpdateWifiStatus event,
    emit,
  ) async {
    emit(state.copyWith(isWifiOn: event.isOn));
  }

  Future<void> _onUpdateBluetoothStatus(
    UpdateBluetoothStatus event,
    emit,
  ) async {
    emit(state.copyWith(isBluetoothOn: event.isBluetoothOn));
  }

  Future<void> _onUpdateInternetStatus(
    UpdateInternetStatus event,
    emit,
  ) async {
    emit(state.copyWith(hasInternet: event.hasInternet));
  }

  Future<void> _onUpdateConnectionStatus(
    UpdateConnectionStatus event,
    emit,
  ) async {
    emit(state.copyWith(connection: event.connection));
  }

  Future<void> _onCheckInternetConnectivity(
    CheckInternetConnectivity event,
    emit,
  ) async {
    bool hasInternet = kIsWeb? true : await ConnectivityWrapper.instance.isConnected;
    if (!hasInternet) {
      DebugLogger.error(
        "No internet, Please check you network connection.",
      );
    }
  }

  @override
  Future<void> close() {
    _connectivity?.cancel();
    _bluetooth?.cancel();
    return super.close();
  }
}
