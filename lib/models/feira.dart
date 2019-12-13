class Feira {
  int id;
  String data;

  Feira({this.id, this.data});

  factory Feira.fromJson(Map<String, dynamic> json) {
    return Feira(
      id: json['ID'],
      data: json['data'],
    );
  }
}
