class Sale {
  final int id;
  final int userId;
  final String saleDate;
  final double priceUnit;
  final String articleName;
  final String articleUnit;
  final String clientName;
  final double quantity;
  final double total;

  Sale({
    required this.id,
    required this.userId,
    required this.saleDate,
    required this.priceUnit,
    required this.articleName,
    required this.articleUnit,
    required this.clientName,
    required this.quantity,
    required this.total,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      userId: json['user_id'],
      saleDate: json['sale_date'],
      priceUnit: json['price_unit'],
      articleName: json['article_name'],
      articleUnit: json['article_unit'],
      clientName: json['client_name'],
      quantity: json['quantity'],
      total: json['total'],
    );
  }
}