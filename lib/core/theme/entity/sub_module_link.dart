class SubModuleLink {
  int id;
  String title;
  String url;

  SubModuleLink({
    required this.id,
    required this.title,
    required this.url,
  });

  factory SubModuleLink.fromJson(Map<String, dynamic> json) {
    return SubModuleLink(
      id: json['id'],
      title: json['title'],
      url: json['url'],
    );
  }

  static List<SubModuleLink> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => SubModuleLink.fromJson(json)).toList();
  }
}
