class customerOrderHistory {
  final String orderId;
  final double price;
  final String time;
  final String date;
  final String status;
  final String paymentMethod;
 final String customerId;


  customerOrderHistory({
    required this.orderId,
    required this.price,
    required this.time,
    required this.date,
    required this.status,
    required this.paymentMethod,
    required this.customerId,
  });
}