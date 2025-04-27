class Activity {
  final int? id;
  final int? accountId;
  final String? date;
  final String? type;
  final String? description;
  final double? amount;

  Activity({
    this.id,
    this.accountId,
    this.date,
    this.type,
    this.description,
    this.amount,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['activity_id'],
      accountId: json['account_id'],
      date: json['date'],
      type: json['type'],
      description: json['description'],
      amount: json['amount'] != null 
          ? double.tryParse(json['amount'].toString()) ?? 0.0
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_id': id,
      'account_id': accountId,
      'date': date,
      'type': type,
      'description': description,
      'amount': amount,
    };
  }
}
