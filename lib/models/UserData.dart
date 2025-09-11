class UserData {
  final String customerName;
  final String email;
  final String pincode;
  final String city;
  final String state;
  final String mobileNo;

  UserData({
    required this.customerName,
    required this.email,
    required this.pincode,
    required this.city,
    required this.state,
    required this.mobileNo,
  });

  Map<String, String> toMap() {
    return {
      'customer_name': customerName,
      'email': email,
      'pincode': pincode,
      'city': city,
      'state': state,
      'mobile_no': mobileNo,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      customerName: map['customer_name'] ?? '',
      email: map['email'] ?? '',
      pincode: map['pincode'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      mobileNo: map['mobile_no'] ?? '',
    );
  }
}