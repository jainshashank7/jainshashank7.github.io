part of 'dashboard_bloc.dart';

abstract class DashboardEvent {}

class FetchMainModuleDetailsEvent extends DashboardEvent {
  FetchMainModuleDetailsEvent();
}

class FetchMainModuleInfoEvent extends DashboardEvent {
  FetchMainModuleInfoEvent();
}

class FetchSubModuleDetailsEvent extends DashboardEvent {
  final int id;

  FetchSubModuleDetailsEvent({required this.id});
}

class FetchSubModuleInfoEvent extends DashboardEvent {
  FetchSubModuleInfoEvent();
}

class FetchSubModuleLinksEvent extends DashboardEvent {
  final int id;

  FetchSubModuleLinksEvent({required this.id});
}

class FetchSubModuleLinksInfoEvent extends DashboardEvent {
  FetchSubModuleLinksInfoEvent();
}

class ResetDashboardState extends DashboardEvent {
  ResetDashboardState();
}
