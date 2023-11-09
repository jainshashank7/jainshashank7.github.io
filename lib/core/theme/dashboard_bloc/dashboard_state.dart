part of 'dashboard_bloc.dart';

class DashboardState {
  final List<MainModuleItem> mainModuleItems;
  final MainModuleInfo mainModuleInfo;
  final List<SubModuleItem> subModuleItems;
  final SubModuleInfo subModuleInfo;
  final Map<int, List<SubModuleLink>> subModuleLinks;

  const DashboardState({
    required this.mainModuleItems,
    required this.mainModuleInfo,
    required this.subModuleItems,
    required this.subModuleInfo,
    required this.subModuleLinks,
  });

  factory DashboardState.initial() {
    return DashboardState(
      mainModuleItems: [],
      mainModuleInfo: MainModuleInfo(info: []),
      subModuleItems: [],
      subModuleInfo: SubModuleInfo(info: []),
      subModuleLinks: {},
    );
  }

  DashboardState copyWith({
    List<MainModuleItem>? mainModuleItems,
    MainModuleInfo? mainModuleInfo,
    List<SubModuleItem>? subModuleItems,
    SubModuleInfo? subModuleInfo,
    Map<int, List<SubModuleLink>>? subModuleLinks,
  }) {
    return DashboardState(
      mainModuleItems: mainModuleItems ?? this.mainModuleItems,
      mainModuleInfo: mainModuleInfo ?? this.mainModuleInfo,
      subModuleItems: subModuleItems ?? this.subModuleItems,
      subModuleInfo: subModuleInfo ?? this.subModuleInfo,
      subModuleLinks: subModuleLinks ?? this.subModuleLinks,
    );
  }

  List<Object?> get props => [
    mainModuleInfo,
    mainModuleItems,
    subModuleItems,
    subModuleInfo,
    subModuleLinks,
  ];
}
