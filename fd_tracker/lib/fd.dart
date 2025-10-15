import 'dart:math';

class FD {
  int? id;
  String title;
  String bankName;
  String accountNo;
  double principal;
  double rate;
  String compounding;
  DateTime startDate;
  DateTime maturityDate;
  String payoutFreq;
  double? maturityAmount;
  double? tds;
  String? documentPath;
  String status;

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
    this.compounding = 'Quarterly',
    required this.startDate,
    required this.maturityDate,
    this.payoutFreq = 'On Maturity',
    this.maturityAmount,
    this.tds,
    this.documentPath,
    this.status = 'Active',
    this.nomineeName,
    this.jointHolder,
    this.remarks,
  });

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

  double calculateMaturityAmount() {
    if (principal <= 0 || rate <= 0) return principal;

    int n;
    switch (compounding.toLowerCase()) {
      case 'monthly':
        n = 12;
        break;
      case 'quarterly':
        n = 4;
        break;
      case 'half-yearly':
        n = 2;
        break;
      case 'yearly':
        n = 1;
        break;
      default:
        n = 4;
    }

    final double t = maturityDate.difference(startDate).inDays / 365.25;
    final double r = rate / 100;

    double amount = principal * pow((1 + (r / n)), (n * t));

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
      'compounding': compounding,
      'startDate': startDate.toIso8601String(),
      'maturityDate': maturityDate.toIso8601String(),
      'payoutFreq': payoutFreq,
      'maturityAmount': calculateMaturityAmount(),
      'tds': tds,
      'documentPath': documentPath,
      'status': status,
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
      compounding: map['compounding'] ?? 'Quarterly',
      startDate: DateTime.parse(map['startDate']),
      maturityDate: DateTime.parse(map['maturityDate']),
      payoutFreq: map['payoutFreq'] ?? 'On Maturity',
      maturityAmount: (map['maturityAmount'] as num?)?.toDouble(),
      tds: (map['tds'] as num?)?.toDouble(),
      documentPath: map['documentPath'],
      status: map['status'] ?? 'Active',
      nomineeName: map['nomineeName'],
      jointHolder: map['jointHolder'],
      remarks: map['remarks'],
    );
  }
}