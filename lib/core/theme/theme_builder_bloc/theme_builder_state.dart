part of 'theme_builder_bloc.dart';

class ThemeBuilderState {
  ThemeBuilderState(
      {required this.themeData,
      required this.dashboardBuilder,
      this.hasCareAssistant});

  final ThemeData themeData;
  final ApiData dashboardBuilder;
  bool? hasCareAssistant = true;
  // final int memberProfileId;
  // final String profileName;
  // final String ageGroup;
  // final bool active;
  @override
  String toString() {
    return 'ThemeBuilderState( themeData: $themeData, dashboardBuilder: $dashboardBuilder)';
  }

  factory ThemeBuilderState.initial() {
    return ThemeBuilderState(
        // memberProfileId: 0,
        // profileName: '',
        // ageGroup: '',
        // active: false,
        dashboardBuilder: ApiData(
          li: DashboardSectionData(
            items: {
              "LI 3": DashboardItem(
                  id: "1",
                  name: "Scheduling",
                  height: 120,
                  width: 220,
                  type: "core",
                  fileId: ''),
              "LI 4": DashboardItem(
                  id: "1",
                  name: "Care Team",
                  height: 120,
                  width: 220,
                  type: "core",
                  fileId: ''),
              "LI 5": DashboardItem(
                  id: "1",
                  name: "Vitals",
                  height: 120,
                  width: 220,
                  type: "core",
                  fileId: ''),
              "LI 6": DashboardItem(
                  id: "1",
                  name: "Medication",
                  height: 120,
                  width: 220,
                  type: "core",
                  fileId: '')
            },
          ),
          gsi: DashboardSectionData(
            items: {
              "GSI 1": DashboardItem(
                  id: "1",
                  name: "Content & Education",
                  height: 120,
                  width: 220,
                  type: "core",
                  fileId: ''),
              "GSI 2": DashboardItem(
                  id: "1",
                  name: "Let's Connect",
                  height: 120,
                  width: 220,
                  type: "core",
                  fileId: ''),
              "GSI 3": DashboardItem(
                  id: "1",
                  name: "Photos",
                  height: 120,
                  width: 220,
                  type: "core",
                  fileId: ''),
              "GSI 4": DashboardItem(
                  id: "1",
                  name: "Entertainment",
                  height: 120,
                  width: 220,
                  type: "core",
                  fileId: ''),
              "GSI 6": DashboardItem(
                  id: "1",
                  name: "Web Links",
                  height: 120,
                  width: 220,
                  type: "core",
                  fileId: ''),
            },
          ),
        ),
        themeData: ThemeData(
            colors: ColorData(
                primary: Color(0xFF595BC4),
                secondary: Color(0xFFAC2734),
                tertiary: Color(0xFF4CBC9A)),
            background: '',
            logo: ''));
  }

  factory ThemeBuilderState.fromJson(Map<String, dynamic> json) {
    return ThemeBuilderState(
      themeData: ThemeData.fromJson(json['page3']),
      dashboardBuilder: ApiData.fromJson(json['page4']['templateData']),
    );
  }

  ThemeBuilderState copyWith({
    ThemeData? functionList,
    ApiData? coreApps,
  }) {
    return ThemeBuilderState(
        // memberProfileId: memberProfileId ?? this.memberProfileId,
        // profileName: profileName ?? this.profileName,
        // ageGroup: ageGroup ?? this.ageGroup,
        // active: active ?? this.active,
        themeData: functionList ?? this.themeData,
        dashboardBuilder: coreApps ?? this.dashboardBuilder);
  }
}

class ApiResponse {
  final ThemeData themeData;
  final ApiData dashboardBuilder;

  ApiResponse({
    required this.themeData,
    required this.dashboardBuilder,
  });
  String toString() {
    return 'ApiResponse(themeData: $themeData, dashboardBuilder: $dashboardBuilder)';
  }

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      themeData: ThemeData.fromJson(json['themeData']),
      dashboardBuilder: ApiData.fromJson(json['dashboardBuilder']),
    );
  }
}

class ThemeData {
  final ColorData colors;
  final String background;
  final String logo;

  ThemeData({
    required this.colors,
    required this.background,
    required this.logo,
  });
  @override
  String toString() {
    return 'ThemeData(colors: $colors, background: $background, logo: $logo)';
  }

  factory ThemeData.fromJson(Map<String, dynamic> json) {
    return ThemeData(
      colors: ColorData.fromJson(json['colorScheme']),
      background: json['background']['image'],
      logo: json['logo']['image'],
    );
  }
}

class ColorData {
  final Color primary;
  final Color secondary;
  final Color tertiary;

  ColorData({
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });
  @override
  String toString() {
    return 'ColorData(primary: $primary, secondary: $secondary, tertiary: $tertiary)';
  }

  factory ColorData.fromJson(Map<String, dynamic> json) {
    return ColorData(
      primary: parseColor(json['colors'][0]),
      secondary: parseColor(json['colors'][1]),
      tertiary: parseColor(json['colors'][0]),
    );
  }
  //#000
  //#0432234
  static Color parseColor(String hexColor) {
    if (hexColor.length == 4) {
      var m =
          Color(int.parse(hexColor.substring(1, 4), radix: 16) + 0xFF000000);
      return m;
    } else {
      // [#2271B1, #EBEFF4, #EBEFF4]
      var m =
          Color(int.parse(hexColor.substring(1, 7), radix: 16) + 0xFF000000);
      print("Color m : $m");
      return m;
    }
  }
}

class ApiData {
  final DashboardSectionData li;
  final DashboardSectionData gsi;

  ApiData({required this.li, required this.gsi});
  String toString() {
    return 'ApiData(li: $li, gsi: $gsi)';
  }

  factory ApiData.fromJson(Map<String, dynamic> json) {
    final dashboardBuilderJson = json as Map<String, dynamic>? ?? {};

    return ApiData(
      li: DashboardSectionData.fromJson(
          dashboardBuilderJson['LI'] as Map<String, dynamic>? ?? {}),
      gsi: DashboardSectionData.fromJson(
          dashboardBuilderJson['GSI'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class DashboardSectionData {
  final Map<String, DashboardItem?> items;

  DashboardSectionData({required this.items});
  @override
  String toString() {
    return 'DashboardSectionData(items: $items)';
  }

  factory DashboardSectionData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? sectionJson = json;

    final Map<String, DashboardItem?> items = sectionJson?.map((key, value) {
          if (value != null) {
            final DashboardItem dashboardItem =
                DashboardItem.fromJson(value as Map<String, dynamic>);
            return MapEntry(key, dashboardItem);
          } else {
            return MapEntry(key, null);
          }
        }) ??
        {};

    return DashboardSectionData(items: items);
  }
}

class DashboardItem {
  final String id;
  final String name;
  final double height;
  final double width;
  final String? androidId;
  final String? iosId;
  final String? type;
  final String? image;
  final String? fileId;
  DashboardItem({
    required this.id,
    required this.name,
    required this.height,
    required this.width,
    required this.fileId,
    this.androidId,
    this.iosId,
    this.type,
    this.image,
  });

  factory DashboardItem.fromJson(Map<String, dynamic> json) {
    return DashboardItem(
        id: json['id'].toString() as String? ?? '',
        name: json['function_name'] as String? ?? '',
        height: 0,
        width: 0,
        androidId: json['android_id'] as String?,
        iosId: json['ios_id'] as String?,
        type: json['function_type'] as String?,
        image: json['image'] as String? ?? '',
        fileId: json['fileId'] as String? ?? '');
  }
  @override
  String toString() {
    return 'DashboardItem(id: $id, name: $name, height: $height, width: $width, androidId: $androidId, iosId: $iosId, type: $type, image: $image, fileId: $fileId)';
  }
}
