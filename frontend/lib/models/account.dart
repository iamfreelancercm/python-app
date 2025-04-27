class Account {
  final int? id;
  final int? clientId;
  final String? accountType;
  final String? openingDate;
  final double? currentBalance;
  final String? currency;

  Account({
    this.id,
    this.clientId,
    this.accountType,
    this.openingDate,
    this.currentBalance,
    this.currency,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['account_id'],
      clientId: json['client_id'],
      accountType: json['account_type'],
      openingDate: json['opening_date'],
      currentBalance: json['current_balance'] != null 
          ? double.tryParse(json['current_balance'].toString()) ?? 0.0
          : 0.0,
      currency: json['currency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': id,
      'client_id': clientId,
      'account_type': accountType,
      'opening_date': openingDate,
      'current_balance': currentBalance,
      'currency': currency,
    };
  }
}
