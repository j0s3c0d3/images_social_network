class Example {
  String? id;
  String? createdAt;
  String? description;
  String? urlSmall;
  String? urlBig;

  Example({this.id, this.createdAt, this.description, this.urlSmall, this.urlBig});

  factory Example.fromJSON(Map<String, dynamic> json) {
    return Example(
      id: json['id'],
      createdAt: json['created_at'] ?? DateTime.now(),
      description: json['description'] ?? "",
      urlSmall: json['urls']['small'] ?? "",
      urlBig: json['urls']['regular'] ?? ""
    );
  }
}