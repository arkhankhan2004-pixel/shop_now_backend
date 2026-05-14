class OrderModel {
  final int id;
  final String customerName;
  final String phone;
  final double totalAmount;
  final String status;
  final String paymentMethod;
  final String createdAt;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      customerName: json['customer_name'] ?? 'Unknown',
      phone: json['phone'] ?? '-',
      totalAmount: double.parse(json['total_amount'].toString()),
      status: json['status'] ?? 'Pending',
      paymentMethod: json['payment_method'] ?? '-',
      createdAt: json['created_at'] ?? '',
    );
  }
}
