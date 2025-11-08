import 'package:intl/intl.dart';

class FD {
  int? id;
  String title;
  String bankName;
  String accountNo;
  double principal;
  double rate;
  DateTime startDate;
  DateTime maturityDate;
  String payoutFreq;
  double? maturityAmount;
  double? tds;
  String? documentPath;
  String status;
  DateTime createdAt; // ADDED: CreatedAt field

  String? nomineeName;
  String? jointHolder;
  String? remarks;

  FD({
    this.id,
    required this.title,
    required this.bankName,
    this.accountNo = '',
    required this.principal,
    required this.rate,
    required this.startDate,
    required this.maturityDate,
    this.payoutFreq = 'On Maturity',
    this.maturityAmount,
    this.tds,
    this.documentPath,
    this.status = 'Active',
    DateTime? createdAt, // ADDED: Optional createdAt parameter
    this.nomineeName,
    this.jointHolder,
    this.remarks,
  }) : createdAt = createdAt ?? startDate; // DEFAULT to startDate if not provided

  int getTenureInMonths() {
    if (maturityDate.isBefore(startDate)) return 0;
    return (maturityDate.year - startDate.year) * 12 +
        (maturityDate.month - startDate.month);
  }

  DateTime getNextInterestDate() {
    if (payoutFreq.toLowerCase() == 'on maturity') {
      return maturityDate;
    }

    DateTime now = DateTime.now();
    DateTime nextInterestDate = startDate;
    int monthIncrement = 0;

    switch (payoutFreq.toLowerCase()) {
      case 'monthly':
        monthIncrement = 1;
        break;
      case 'quarterly':
        monthIncrement = 3;
        break;
      case 'half-yearly':
        monthIncrement = 6;
        break;
      default:
        return maturityDate;
    }

    while (nextInterestDate.isBefore(now)) {
      nextInterestDate = DateTime(
        nextInterestDate.year,
        nextInterestDate.month + monthIncrement,
        nextInterestDate.day,
      );
    }
    return nextInterestDate;
  }

  /// ✅ Simple Interest Maturity Calculation (no compounding)
  double calculateMaturityAmount() {
    if (principal <= 0 || rate <= 0) return principal;

    final double t = maturityDate.difference(startDate).inDays / 365;
    final double r = rate / 100;
    final double si = principal * r * t;
    final double amount = principal + si;

    return double.parse(amount.toStringAsFixed(2));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'bankName': bankName,
      'accountNo': accountNo,
      'principal': principal,
      'rate': rate,
      'startDate': startDate.toIso8601String(),
      'maturityDate': maturityDate.toIso8601String(),
      'payoutFreq': payoutFreq,
      'maturityAmount': calculateMaturityAmount(),
      'tds': tds,
      'documentPath': documentPath,
      'status': status,
      'createdAt': createdAt.toIso8601String(), // ADDED: Include createdAt
      'nomineeName': nomineeName,
      'jointHolder': jointHolder,
      'remarks': remarks,
    };
  }

  factory FD.fromMap(Map<String, dynamic> map) {
    return FD(
      id: map['id'],
      title: map['title'],
      bankName: map['bankName'],
      accountNo: map['accountNo'] ?? '',
      principal: (map['principal'] as num).toDouble(),
      rate: (map['rate'] as num).toDouble(),
      startDate: DateTime.parse(map['startDate']),
      maturityDate: DateTime.parse(map['maturityDate']),
      payoutFreq: map['payoutFreq'] ?? 'On Maturity',
      maturityAmount: (map['maturityAmount'] as num?)?.toDouble(),
      tds: (map['tds'] as num?)?.toDouble(),
      documentPath: map['documentPath'],
      status: map['status'] ?? 'Active',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.parse(map['startDate']), // ADDED: Handle createdAt
      nomineeName: map['nomineeName'],
      jointHolder: map['jointHolder'],
      remarks: map['remarks'],
    );
  }

  FD copyWith({
    int? id,
    String? title,
    String? bankName,
    String? accountNo,
    double? principal,
    double? rate,
    DateTime? startDate,
    DateTime? maturityDate,
    String? payoutFreq,
    double? maturityAmount,
    double? tds,
    String? documentPath,
    String? status,
    DateTime? createdAt, // ADDED: createdAt in copyWith
    String? nomineeName,
    String? jointHolder,
    String? remarks,
  }) {
    return FD(
      id: id ?? this.id,
      title: title ?? this.title,
      bankName: bankName ?? this.bankName,
      accountNo: accountNo ?? this.accountNo,
      principal: principal ?? this.principal,
      rate: rate ?? this.rate,
      startDate: startDate ?? this.startDate,
      maturityDate: maturityDate ?? this.maturityDate,
      payoutFreq: payoutFreq ?? this.payoutFreq,
      maturityAmount: maturityAmount ?? this.maturityAmount,
      tds: tds ?? this.tds,
      documentPath: documentPath ?? this.documentPath,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt, // ADDED
      nomineeName: nomineeName ?? this.nomineeName,
      jointHolder: jointHolder ?? this.jointHolder,
      remarks: remarks ?? this.remarks,
    );
  }
}