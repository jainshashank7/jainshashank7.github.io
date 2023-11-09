part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {}

class AppInitializedEvent extends AppEvent {
  @override
  List<Object?> get props => [];
}

class AppInitializedOfflineEvent extends AppEvent {
  @override
  List<Object?> get props => [];
}
