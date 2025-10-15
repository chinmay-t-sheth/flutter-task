class InterestLog {
  final int? id;
  final int fdId;
  final DateTime date;
  final double amount;
  final String? note;

  InterestLog({
    this.id,
    required this.fdId,
    required this.date,
    required this.amount,
    this.note,
  });

  InterestLog copyWith({
    int? id,
    int? fdId,
    DateTime? date,
    double? amount,
    String? note,
  }) {
    return InterestLog(
      id: id ?? this.id,
      fdId: fdId ?? this.fdId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fdId': fdId,
      'date': date.toIso8601String(),
      'amount': amount,
      'note': note,
    };
  }

  factory InterestLog.fromMap(Map<String, dynamic> map) {
    return InterestLog(
      id: map['id'],
      fdId: map['fdId'],
      date: DateTime.parse(map['date']),
      amount: (map['amount'] as num).toDouble(),
      note: map['note'],
    );
  }

  @override
  String toString() {
    return 'InterestLog(id: $id, fdId: $fdId, date: $date, amount: $amount, note: $note)';
  }
}