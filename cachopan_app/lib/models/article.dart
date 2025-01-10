class Article {
  final int id;
  final String lot;
  final String name;
  final double price;
  final String unit;
  final int userId;
  final String date;

  Article({
    required this.id,
    required this.lot,
    required this.name,
    required this.price,
    required this.unit,
    required this.userId,
    required this.date,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      lot: json['lot'],
      name: json['name'],
      price: json['price'].toDouble(),
      unit: json['unit'],
      userId: json['user_id'],
      date: json['date'],
    );
  }
}