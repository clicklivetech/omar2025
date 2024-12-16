class Address {
  final String id;
  final String street;
  final String city;
  final String building;
  final String floor;
  final String landmark;
  final String phone;
  final bool isDefault;

  Address({
    required this.id,
    required this.street,
    required this.city,
    required this.building,
    required this.floor,
    required this.landmark,
    required this.phone,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'city': city,
      'building': building,
      'floor': floor,
      'landmark': landmark,
      'phone': phone,
      'isDefault': isDefault,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      street: json['street'],
      city: json['city'],
      building: json['building'],
      floor: json['floor'],
      landmark: json['landmark'],
      phone: json['phone'],
      isDefault: json['isDefault'] ?? false,
    );
  }
}
