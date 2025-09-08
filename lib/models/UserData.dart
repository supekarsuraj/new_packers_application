// user_model.dart
class UserData {
  final String customerName;
  final String email;
  final String password;
  final String pincode;
  final String city;
  final String state;
  final String mobileNo;

  UserData({
    required this.customerName,
    required this.email,
    required this.password,
    required this.pincode,
    required this.city,
    required this.state,
    required this.mobileNo,
  });

  // Convert UserData to a map for API requests or storage
  Map<String, String> toMap() {
    return {
      'customer_name': customerName,
      'email': email,
      'password': password,
      'pincode': pincode,
      'city': city,
      'state': state,
      'mobile_no': mobileNo,
    };
  }

  // Factory method to create UserData from a map (e.g., API response)
  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      customerName: map['customer_name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      pincode: map['pincode'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      mobileNo: map['mobile_no'] ?? '',
    );
  }
}