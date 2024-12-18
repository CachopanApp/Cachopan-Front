class Client {
  final int id;
  final String name;
  final String? email;
  final String? number;
  final int userId;

  Client({
    required this.id,
    required this.name,
    this.email,
    this.number,
    required this.userId,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      number: json['number'],
      userId: json['user_id'],
    );
  }
}
