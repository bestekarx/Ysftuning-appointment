class Services {
  int? id;
  String? services_name;

  Services({
    this.id,
    this.services_name,
  });

  factory Services.fromJson(Map<String, dynamic> json) {
    return Services(
      id: json['id'] as int,
      services_name: json['services_name'] as String,
    );
  }
}
