import 'package:flutter/foundation.dart';
import 'dart:math';
import 'fd.dart';
import 'db_helper.dart';
import 'interest_log.dart';
import 'enums.dart';

class FDProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();

  List<FD> _fds = [];
  Map<int, List<InterestLog>> _interestLogs = {};
  bool _isLoading = false;

  List<FD> get fds => _fds;
  Map<int, List<InterestLog>> get interestLogs => _interestLogs;
  bool get isLoading => _isLoading;

  double get totalPrincipal =>
      _fds.fold(0.0, (sum, fd) => sum + fd.principal);
  double get activePrincipal => _fds
      .where((fd) => fd.status.toLowerCase() == 'active')
      .fold(0.0, (sum, fd) => sum + fd.principal);
  double get totalMaturity =>
      _fds.fold(0.0, (sum, fd) => sum + (fd.maturityAmount ?? 0));

  double get averageRate {
    final activeFds =
    _fds.where((fd) => fd.status.toLowerCase() == 'active').toList();
    return activeFds.isEmpty
        ? 0
        : activeFds.fold<double>(0, (sum, fd) => sum + fd.rate) /
        activeFds.length;
  }

  double getTotalInterestForFD(int fdId) {
    final logs = _interestLogs[fdId] ?? [];
    return logs.fold(0.0, (sum, log) => sum + log.amount);
  }

  double upcomingInterest(int fdId) {
    final fd = _fds.firstWhere(
          (f) => f.id == fdId,
      orElse: () => FD(
        title: '',
        bankName: '',
        principal: 0,
        rate: 0,
        startDate: DateTime.now(),
        maturityDate: DateTime.now(),
      ),
    );
    if (fd.principal <= 0 ||
        fd.rate <= 0 ||
        fd.payoutFreq.toLowerCase() == 'on maturity') return 0.0;
    return _calculatePeriodInterest(fd);
  }

  double getInterestForMonth(DateTime month) {
    final now = DateTime.now();
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    double total = 0.0;

    for (var fd in _fds) {
      if (fd.status.toLowerCase() != 'active') continue;
      if (fd.principal <= 0 || fd.rate <= 0) continue;

      final monthsIncrement = _getMonthsIncrement(fd.payoutFreq);
      if (monthsIncrement == 0) continue;

      DateTime nextPayout = _getNextPayoutDate(fd.startDate, monthsIncrement);

      while (nextPayout.isBefore(fd.maturityDate) ||
          nextPayout.isAtSameMomentAs(fd.maturityDate)) {
        if (!nextPayout.isBefore(now) && !nextPayout.isAfter(endOfMonth)) {
          final logs = _interestLogs[fd.id ?? -1] ?? [];
          final alreadyPaid = logs.any((log) =>
          log.date.year == nextPayout.year &&
              log.date.month == nextPayout.month &&
              log.date.day == nextPayout.day);

          if (!alreadyPaid) {
            total += _calculatePeriodInterest(fd);
          }
        }
        nextPayout = DateTime(
            nextPayout.year, nextPayout.month + monthsIncrement, nextPayout.day);
      }
    }

    return total;
  }

  double get totalInterestReceived {
    return _fds.fold(0.0, (sum, fd) {
      if (fd.id != null) return sum + getTotalInterestForFD(fd.id!);
      return sum;
    });
  }

  double get totalInterestReceivedActive {
    return _fds
        .where((fd) => fd.status.toLowerCase() == 'active')
        .fold(0.0, (sum, fd) {
      if (fd.id != null) return sum + getTotalInterestForFD(fd.id!);
      return sum;
    });
  }

  double get totalInterestReceivedMatured {
    return _fds
        .where((fd) => fd.status.toLowerCase() == 'matured')
        .fold(0.0, (sum, fd) {
      if (fd.id != null) return sum + getTotalInterestForFD(fd.id!);
      return sum;
    });
  }

  double get totalUpcomingInterest {
    return _fds.fold(0.0, (sum, fd) {
      if (fd.id != null && fd.status.toLowerCase() == 'active') {
        return sum + upcomingInterest(fd.id!);
      }
      return sum;
    });
  }

  double get portfolioYield {
    final totalP = totalPrincipal;
    if (totalP == 0) return 0;
    return _fds.fold(0.0, (sum, fd) => sum + (fd.principal * fd.rate)) / totalP;
  }

  double get healthScore {
    final activeCount = _fds.where((fd) => fd.status.toLowerCase() == 'active').length;
    if (activeCount == 0) return 0;
    final daysToMaturity =
    _fds.map(_daysToMaturity).where((d) => d > 0).toList();
    final avgDays = daysToMaturity.isEmpty
        ? 0
        : daysToMaturity.reduce((a, b) => a + b) / daysToMaturity.length;
    final diversity =
        _fds.map((fd) => fd.bankName).toSet().length / activeCount.clamp(1, double.infinity);
    return ((avgDays / 365 * 50) + (diversity * 50)).clamp(0, 100);
  }

  List<FD> getUpcomingMaturities(int days) {
    final now = DateTime.now();
    final cutoff = now.add(Duration(days: days));
    return _fds
        .where((fd) =>
    fd.status.toLowerCase() == 'active' &&
        fd.maturityDate.isAfter(now) &&
        fd.maturityDate.isBefore(cutoff.add(const Duration(days: 1))))
        .toList();
  }

  List<double> getMonthlyInterestHistory(int months) {
    final now = DateTime.now();
    List<double> history = List.filled(months, 0.0);
    for (int i = 0; i < months; i++) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      if (monthDate.isAfter(now)) {
        history[i] = 0.0;
      } else {
        history[i] = getInterestForMonth(monthDate);
      }
    }
    return history.reversed.toList();
  }

  int _daysToMaturity(FD fd) {
    return fd.maturityDate
        .difference(DateTime.now())
        .inDays
        .clamp(0, double.infinity)
        .toInt();
  }

  Map<String, double> get statusDistribution {
    final active = _fds
        .where((fd) => fd.status.toLowerCase() == 'active')
        .fold(0.0, (sum, fd) => sum + fd.principal);
    final matured = _fds
        .where((fd) => fd.status.toLowerCase() == 'matured')
        .fold(0.0, (sum, fd) => sum + fd.principal);
    final total = active + matured;
    if (total == 0) return {};
    return {
      'Active': (active / total) * 100,
      'Matured': (matured / total) * 100,
    };
  }

  Map<String, double> get bankDistribution {
    final bankMap = <String, double>{};
    for (var fd in _fds) {
      bankMap[fd.bankName] = (bankMap[fd.bankName] ?? 0) + fd.principal;
    }
    final total = bankMap.values.fold(0.0, (sum, v) => sum + v);
    if (total == 0) return {};
    return bankMap.map((k, v) => MapEntry(k, (v / total) * 100));
  }

  FDProvider();

  Future<void> fetchFDsAndLogs() async {
    _isLoading = true;
    notifyListeners();
    _fds = await _dbHelper.getFDs();

    final now = DateTime.now();
    for (var fd in _fds) {
      if (fd.maturityDate.isBefore(now) && fd.status.toLowerCase() != 'matured') {
        fd.status = 'Matured';
        if (fd.id != null) {
          await _dbHelper.updateFD(fd);
        }
      }
    }

    _interestLogs.clear();
    for (var fd in _fds) {
      if (fd.id != null) {
        final logMaps = await _dbHelper.getInterestLogs(fd.id!);
        _interestLogs[fd.id!] = logMaps.map((e) => InterestLog.fromMap(e)).toList();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addFD(FD fd) async {
    final int newId = await _dbHelper.insertFD(fd);
    await _autoLogPastInterests(newId, fd);
    await fetchFDsAndLogs();
  }

  Future<void> updateFD(FD fd) async {
    await _dbHelper.updateFD(fd);
    await _autoLogPastInterests(fd.id!, fd);
    await fetchFDsAndLogs();
  }

  Future<void> deleteFD(int id) async {
    await _dbHelper.deleteFD(id);
    await fetchFDsAndLogs();
  }

  Future<void> addInterest(int fdId, double amount, {String? note}) async {
    await _dbHelper.insertInterest(fdId, amount, note: note);
    await fetchFDsAndLogs();
  }

  Future<void> addInterestWithDate(int fdId, double amount,
      {String? note, required DateTime date}) async {
    await _dbHelper.insertInterest(fdId, amount, note: note, customDate: date);
    await fetchFDsAndLogs();
  }

  Future<void> deleteInterestLog(int logId) async {
    final dbClient = await _dbHelper.database;
    await dbClient.delete('interest_log', where: 'id = ?', whereArgs: [logId]);
    await fetchFDsAndLogs();
  }

  // FIXED: Filter and Sort Method
  List<FD> getFilteredAndSortedFDs({
    required FilterStatus filter,
    required FDSortOption sortBy,
    required bool ascending,
  }) {
    List<FD> filtered = List.from(_fds);

    print('🔍 FD PROVIDER: Starting with ${_fds.length} total FDs');
    print('🔍 FD PROVIDER: Applying filter: $filter, sort: $sortBy, ascending: $ascending');

    // Apply Filter - FIXED LOGIC
    if (filter != FilterStatus.all) {
      final targetStatus = filter == FilterStatus.active ? 'active' : 'matured';
      print('🔍 FD PROVIDER: Looking for status: $targetStatus');

      filtered = filtered.where((fd) {
        final fdStatus = fd.status.toLowerCase();
        final matches = fdStatus == targetStatus;
        if (matches) {
          print('✅ INCLUDING: "${fd.title}" - Status: $fdStatus');
        }
        return matches;
      }).toList();
    } else {
      print('🔍 FD PROVIDER: Showing all FDs (no filter)');
    }

    print('🔍 FD PROVIDER: After filter - ${filtered.length} FDs remaining');

    // Apply Sort - FIXED: Use proper fields
    if (filtered.isNotEmpty) {
      filtered.sort((a, b) {
        int comparison = 0;
        switch (sortBy) {
          case FDSortOption.maturityDate:
            comparison = a.maturityDate.compareTo(b.maturityDate);
            break;
          case FDSortOption.principal:
            comparison = a.principal.compareTo(b.principal);
            break;
          case FDSortOption.interestRate:
            comparison = a.rate.compareTo(b.rate);
            break;
          case FDSortOption.creationDate:
            comparison = a.createdAt.compareTo(b.createdAt);
            break;
          case FDSortOption.bankName:
            comparison = a.bankName.compareTo(b.bankName);
            break;
        }
        return ascending ? comparison : -comparison;
      });
    }

    print('🔍 FD PROVIDER: Final result - ${filtered.length} FDs');
    for (var fd in filtered) {
      print('📋 FINAL: "${fd.title}" - Status: ${fd.status} - Maturity: ${fd.maturityDate}');
    }

    return filtered;
  }

  Future<void> _autoLogPastInterests(int fdId, FD fd) async {
    final now = DateTime.now();
    if (fd.startDate.isAfter(now)) return;

    final periodInterest = _calculatePeriodInterest(fd);
    if (periodInterest <= 0) return;

    if (fd.payoutFreq.toLowerCase() == 'on maturity') {
      if (fd.status.toLowerCase() == 'matured') {
        final maturityInterest = fd.calculateMaturityAmount() - fd.principal;
        await _dbHelper.insertInterest(fdId, maturityInterest,
            note: 'Maturity interest received');
      }
      return;
    }

    int monthsIncrement = _getMonthsIncrement(fd.payoutFreq);
    if (monthsIncrement == 0) return;

    DateTime currentDate = _getNextPayoutDate(fd.startDate, monthsIncrement);
    final endDate = fd.maturityDate.isBefore(now) ? fd.maturityDate : now;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      final existingLogs = await _dbHelper.getInterestLogs(fdId);
      final hasLogForDate = existingLogs.any((logMap) {
        final logDate = DateTime.parse(logMap['date']);
        return logDate.year == currentDate.year &&
            logDate.month == currentDate.month &&
            logDate.day == currentDate.day;
      });

      if (!hasLogForDate) {
        await _dbHelper.insertInterest(fdId, periodInterest,
            note: '${fd.payoutFreq} payout', customDate: currentDate);
      }

      currentDate = DateTime(
          currentDate.year, currentDate.month + monthsIncrement, currentDate.day);
    }
  }

  double _calculatePeriodInterest(FD fd) {
    switch (fd.payoutFreq.toLowerCase()) {
      case 'monthly':
        return (fd.principal * (fd.rate / 100)) / 12;
      case 'quarterly':
        return (fd.principal * (fd.rate / 100)) / 4;
      case 'half-yearly':
        return (fd.principal * (fd.rate / 100)) / 2;
      case 'yearly':
        return (fd.principal * (fd.rate / 100));
      default:
        return 0;
    }
  }

  int _getMonthsIncrement(String payoutFreq) {
    switch (payoutFreq.toLowerCase()) {
      case 'monthly':
        return 1;
      case 'quarterly':
        return 3;
      case 'half-yearly':
        return 6;
      case 'yearly':
        return 12;
      default:
        return 0;
    }
  }

  DateTime _getNextPayoutDate(DateTime startDate, int monthsIncrement) {
    DateTime nextDate = DateTime(startDate.year, startDate.month, startDate.day);
    if (nextDate.isAfter(DateTime.now())) return nextDate;
    return DateTime(nextDate.year, nextDate.month + monthsIncrement, nextDate.day);
  }

  // Add sample data for testing
  void addSampleDataForTesting() {
    _fds.addAll([
      FD(
        title: 'SBI Savings FD',
        bankName: 'State Bank of India',
        principal: 50000,
        rate: 6.5,
        startDate: DateTime.now().subtract(Duration(days: 30)),
        maturityDate: DateTime.now().add(Duration(days: 60)),
        status: 'Active',
        payoutFreq: 'Monthly',
        createdAt: DateTime.now().subtract(Duration(days: 30)),
      ),
      FD(
        title: 'HDFC Premium FD',
        bankName: 'HDFC Bank',
        principal: 100000,
        rate: 7.2,
        startDate: DateTime.now().subtract(Duration(days: 180)),
        maturityDate: DateTime.now().add(Duration(days: 180)),
        status: 'Active',
        payoutFreq: 'Quarterly',
        createdAt: DateTime.now().subtract(Duration(days: 180)),
      ),
      FD(
        title: 'ICICI Completed FD',
        bankName: 'ICICI Bank',
        principal: 75000,
        rate: 6.8,
        startDate: DateTime.now().subtract(Duration(days: 400)),
        maturityDate: DateTime.now().subtract(Duration(days: 10)),
        status: 'Matured',
        payoutFreq: 'On Maturity',
        createdAt: DateTime.now().subtract(Duration(days: 400)),
      ),
    ]);
    notifyListeners();
    print('✅ Sample data added for testing');
  }
}