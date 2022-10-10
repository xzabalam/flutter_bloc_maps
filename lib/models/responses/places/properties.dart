import 'dart:convert';

class Properties {
  Properties({
    required this.accuracy,
  });

  final String? accuracy;

  factory Properties.fromJson(String str) =>
      Properties.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Properties.fromMap(Map<String, dynamic> json) => Properties(
        accuracy: json["accuracy"],
      );

  Map<String, dynamic> toMap() => {
        "accuracy": accuracy,
      };
}
