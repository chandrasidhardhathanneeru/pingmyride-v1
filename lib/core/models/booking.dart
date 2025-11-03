class Booking {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String busId;
  final String routeId;
  final String busNumber;
  final String routeName;
  final DateTime bookingDate;
  final String pickupLocation;
  final String dropLocation;
  final String driverName;
  final String driverPhone;
  final BookingStatus status;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  
  // Payment details
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final double? amount;

  Booking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.busId,
    required this.routeId,
    required this.busNumber,
    required this.routeName,
    required this.bookingDate,
    required this.pickupLocation,
    required this.dropLocation,
    required this.driverName,
    required this.driverPhone,
    this.status = BookingStatus.confirmed,
    this.cancelledAt,
    required this.createdAt,
    this.paymentId,
    this.orderId,
    this.signature,
    this.amount,
  });

  factory Booking.fromMap(Map<String, dynamic> map, String id) {
    return Booking(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      busId: map['busId'] ?? '',
      routeId: map['routeId'] ?? '',
      busNumber: map['busNumber'] ?? '',
      routeName: map['routeName'] ?? '',
      bookingDate: map['bookingDate']?.toDate() ?? DateTime.now(),
      pickupLocation: map['pickupLocation'] ?? '',
      dropLocation: map['dropLocation'] ?? '',
      driverName: map['driverName'] ?? '',
      driverPhone: map['driverPhone'] ?? '',
      status: BookingStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => BookingStatus.confirmed,
      ),
      cancelledAt: map['cancelledAt']?.toDate(),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      paymentId: map['paymentId'],
      orderId: map['orderId'],
      signature: map['signature'],
      amount: map['amount']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'busId': busId,
      'routeId': routeId,
      'busNumber': busNumber,
      'routeName': routeName,
      'bookingDate': bookingDate,
      'pickupLocation': pickupLocation,
      'dropLocation': dropLocation,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'status': status.name,
      'cancelledAt': cancelledAt,
      'createdAt': createdAt,
      'paymentId': paymentId,
      'orderId': orderId,
      'signature': signature,
      'amount': amount,
    };
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? busId,
    String? routeId,
    String? busNumber,
    String? routeName,
    DateTime? bookingDate,
    String? pickupLocation,
    String? dropLocation,
    String? driverName,
    String? driverPhone,
    BookingStatus? status,
    DateTime? cancelledAt,
    DateTime? createdAt,
    String? paymentId,
    String? orderId,
    String? signature,
    double? amount,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      busId: busId ?? this.busId,
      routeId: routeId ?? this.routeId,
      busNumber: busNumber ?? this.busNumber,
      routeName: routeName ?? this.routeName,
      bookingDate: bookingDate ?? this.bookingDate,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropLocation: dropLocation ?? this.dropLocation,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      status: status ?? this.status,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
      paymentId: paymentId ?? this.paymentId,
      orderId: orderId ?? this.orderId,
      signature: signature ?? this.signature,
      amount: amount ?? this.amount,
    );
  }
}

enum BookingStatus {
  confirmed('Confirmed'),
  cancelled('Cancelled'),
  completed('Completed');

  const BookingStatus(this.label);
  final String label;
}