import 'dart:convert';

class Context {
  Context({
    required this.id,
    required this.textEs,
    required this.text,
    required this.wikidata,
    required this.languageEs,
    required this.language,
    required this.shortCode,
  });

  final String id;
  final String textEs;
  final String text;
  final String? wikidata;
  final String? languageEs;
  final String? language;
  final String? shortCode;

  factory Context.fromJson(String str) => Context.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Context.fromMap(Map<String, dynamic> json) => Context(
        id: json["id"],
        textEs: json["text_es"],
        text: json["text"],
        wikidata: json["wikidata"],
        languageEs: json["language_es"],
        language: json["language"],
        shortCode: json["short_code"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "text_es": textEs,
        "text": text,
        "wikidata": wikidata,
        "language_es": languageEs,
        "language": language,
        "short_code": shortCode,
      };
}
