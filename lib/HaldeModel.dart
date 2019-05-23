import 'dart:convert';

Halde haldeFromJson(String str) {
  final jsonData = json.decode(str);
  return Halde.fromJson(jsonData);
}

String haldeToJson(Halde data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Halde {
  int id;
  String kontaktName;
  String kontaktId;
  String betreff;
  String beschreibung;
  int erstellt;
  int faellig;
  int typ;
  String fotoPfad;

  Halde(
      {this.id,
      this.kontaktName,
      this.kontaktId,
      this.betreff,
      this.beschreibung,
      this.erstellt,
      this.faellig,
      this.typ,
      this.fotoPfad});

  factory Halde.fromJson(Map<String, dynamic> json) => new Halde(
      id: json["id"],
      kontaktName: json["kontaktName"],
      kontaktId: json["kontaktId"],
      betreff: json["betreff"],
      beschreibung: json["beschreibung"],
      erstellt: json["erstellt"],
      faellig: json["faellig"],
      typ: json["typ"],
      fotoPfad: json["fotoPfad"]);

  Map<String, dynamic> toMap() => {
        "id": id,
        "kontaktName": kontaktName,
        "kontaktId": kontaktId,
        "betreff": betreff,
        "beschreibung": beschreibung,
        "erstellt": erstellt,
        "faellig": faellig,
        "typ": typ,
        "fotoPfad": fotoPfad
      };
}
