class Client {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? birthDate;
  final String? riskProfile;
  final String? segment;
  final double? totalAssets;

  Client({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.birthDate,
    this.riskProfile,
    this.segment,
    this.totalAssets,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['client_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      birthDate: json['birth_date'],
      riskProfile: json['risk_profile'],
      segment: json['segment'],
      totalAssets: json['total_assets'] != null 
          ? double.tryParse(json['total_assets'].toString()) ?? 0.0
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'birth_date': birthDate,
      'risk_profile': riskProfile,
      'segment': segment,
      'total_assets': totalAssets,
    };
  }
}
