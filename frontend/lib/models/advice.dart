class Advice {
  final int id;
  final String title;
  final String description;

  Advice({required this.id, required this.title, required this.description});

  factory Advice.fromJson(Map<String, dynamic> json) => Advice(
        id: json['ID'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
      );
}
