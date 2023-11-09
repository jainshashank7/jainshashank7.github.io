import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../enitity/user.dart';


part 'app_event.dart';

part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({
    required User me,
  })  : _me = me,
        super(AppState.initial()) {
    on<AppInitializedEvent>(_onAppInitializedEventToState);
    on<AppInitializedOfflineEvent>(_onAppInitializedOfflineEventToState);
  }

  final User _me;


  void _onAppInitializedEventToState(AppInitializedEvent event, emit) async {
    emit(state.copyWith(initialized: true));
  }

  Future<void> _onAppInitializedOfflineEventToState(
    AppInitializedOfflineEvent event,
    emit,
  ) async {
    emit(state.copyWith(initialized: true));
  }
}
