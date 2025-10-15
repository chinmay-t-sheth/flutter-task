// lib/fd_provider.dart
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

  double get totalPrincipal => _fds.fold(0.0, (sum, fd) => sum + fd.principal);
  double get activePrincipal => _fds.where((fd) => fd.status.toLowerCase() == 'active').fold(0.0, (sum, fd) => sum + fd.principal);
  double get totalMaturity => _fds.fold(0.0, (sum, fd) => sum + (fd.maturityAmount ?? 0));
  double get averageRate {
    final activeFds = _fds.where((fd) => fd.status.toLowerCase() == 'active').toList();
    return activeFds.isEmpty ? 0 : activeFds.fold<double>(0, (sum, fd) => sum + fd.rate) / activeFds.length;
  }

  double get totalInterestReceived {
    return _fds.fold(0.0, (sum, fd) {
      if (fd.id != null) {
        return sum + getTotalInterestForFD(fd.id!);
      }
      return sum;
    });
  }

  double get totalInterestReceivedActive {
    return _fds
        .where((fd) => fd.status.toLowerCase() == 'active')
        .fold(0.0, (sum, fd) {
      if (fd.id != null) {
        return sum + getTotalInterestForFD(fd.id!);
      }
      return sum;
    });
  }

  double get totalInterestReceivedMatured {
    return _fds
        .where((fd) => fd.status.toLowerCase() == 'matured')
        .fold(0.0, (sum, fd) {
      if (fd.id != null) {
        return sum + getTotalInterestForFD(fd.id!);
      }
      return sum;
    });
  }

  FDProvider() {
    // Removed initial fetch from constructor to avoid sync notify during app init
  }

  Future<void> fetchFDsAndLogs() async {
    _isLoading = true;
    notifyListeners(); // Safe now since called post-build
    _fds = await _dbHelper.getFDs();

    // Auto-update status for matured FDs
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

  Future<void> addInterestWithDate(int fdId, double amount, {String? note, required DateTime date}) async {
    await _dbHelper.insertInterest(fdId, amount, note: note, customDate: date);
    await fetchFDsAndLogs();
  }

  Future<void> deleteInterestLog(int logId) async {
    final dbClient = await _dbHelper.database;
    await dbClient.delete('interest_log', where: 'id = ?', whereArgs: [logId]);
    await fetchFDsAndLogs();
  }

  List<InterestLog> getLogsForFD(int fdId) {
    return _interestLogs[fdId] ?? [];
  }

  double getTotalInterestForFD(int fdId) {
    final logs = getLogsForFD(fdId);
    return logs.fold(0.0, (sum, log) => sum + log.amount);
  }

  double upcomingInterest(int fdId) {
    try {
      final fd = _fds.firstWhere((element) => element.id == fdId);

      if (fd.status.toLowerCase() != 'active' || fd.maturityDate.isBefore(DateTime.now())) {
        return 0.00;
      }

      double interest = 0;
      switch (fd.payoutFreq.toLowerCase()) {
        case 'monthly':
          interest = (fd.principal * (fd.rate / 100)) / 12;
          break;
        case 'quarterly':
          interest = (fd.principal * (fd.rate / 100)) / 4;
          break;
        case 'half-yearly':
          interest = (fd.principal * (fd.rate / 100)) / 2;
          break;
        case 'yearly':
          interest = (fd.principal * (fd.rate / 100));
          break;
        case 'on maturity':
        default:
          interest = 0;
          break;
      }
      return double.parse(interest.toStringAsFixed(2));
    } catch (e) {
      debugPrint("Error finding FD for upcoming interest calculation: $e");
      return 0.0;
    }
  }

  double getInterestForMonth(DateTime month) {
    double total = 0;
    for (var fd in _fds) {
      if (fd.id != null) {
        final logs = getLogsForFD(fd.id!);
        total += logs
            .where((log) => log.date.month == month.month && log.date.year == month.year)
            .fold(0.0, (sum, log) => sum + log.amount);
      }
    }
    return total;
  }

  Map<String, double> getBankDistribution() {
    Map<String, double> dist = {};
    for (var fd in _fds) {
      dist[fd.bankName] = (dist[fd.bankName] ?? 0) + fd.principal;
    }
    return dist;
  }

  Map<String, double> getMonthlyInterestTrend() {
    Map<String, double> trend = {};
    final now = DateTime.now();
    for (int i = 0; i < 6; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      trend[key] = getInterestForMonth(date);
    }
    return trend;
  }

  List<FD> getProcessedFDs({required FilterStatus filter, required FDSortOption sortBy, required bool isAscending}) {
    List<FD> filtered = _fds;
    if (filter != FilterStatus.all) {
      filtered = filtered.where((fd) =>
      (filter == FilterStatus.active && fd.status.toLowerCase() == 'active') ||
          (filter == FilterStatus.matured && fd.status.toLowerCase() == 'matured')
      ).toList();
    }

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
          comparison = a.startDate.compareTo(b.startDate);
          break;
        case FDSortOption.bankName:
          comparison = a.bankName.compareTo(b.bankName);
          break;
      }
      return isAscending ? comparison : -comparison;
    });

    return filtered;
  }

  Future<void> _autoLogPastInterests(int fdId, FD fd) async {
    final now = DateTime.now();
    if (fd.startDate.isAfter(now)) return; // Future FD, no past logs

    final periodInterest = _calculatePeriodInterest(fd);
    if (periodInterest <= 0) return;

    if (fd.payoutFreq.toLowerCase() == 'on maturity') {
      // Handle on maturity
      if (fd.status.toLowerCase() == 'matured') {
        final maturityInterest = fd.calculateMaturityAmount() - fd.principal;
        await _dbHelper.insertInterest(fdId, maturityInterest, note: 'Maturity interest received');
      }
      return;
    }

    // For periodic payouts
    int monthsIncrement = _getMonthsIncrement(fd.payoutFreq);
    if (monthsIncrement == 0) return;

    DateTime currentDate = _getNextPayoutDate(fd.startDate, monthsIncrement);
    final endDate = fd.maturityDate.isBefore(now) ? fd.maturityDate : now;

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      // Check if already logged for this date (to avoid duplicates on update)
      final existingLogs = await _dbHelper.getInterestLogs(fdId);
      final hasLogForDate = existingLogs.any((logMap) {
        final logDate = DateTime.parse(logMap['date']);
        return logDate.year == currentDate.year &&
            logDate.month == currentDate.month &&
            logDate.day == currentDate.day;
      });

      if (!hasLogForDate) {
        await _dbHelper.insertInterest(fdId, periodInterest, note: '${fd.payoutFreq} payout', customDate: currentDate);
      }

      currentDate = DateTime(
        currentDate.year,
        currentDate.month + monthsIncrement,
        currentDate.day,
      );
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
      case 'monthly': return 1;
      case 'quarterly': return 3;
      case 'half-yearly': return 6;
      case 'yearly': return 12;
      default: return 0;
    }
  }

  DateTime _getNextPayoutDate(DateTime startDate, int monthsIncrement) {
    // Align to the start date's day, assuming payout on the same day each period
    DateTime nextDate = DateTime(startDate.year, startDate.month, startDate.day);
    if (nextDate.isAfter(DateTime.now())) {
      return nextDate;
    }
    // For past, the first payout is after startDate
    nextDate = DateTime(nextDate.year, nextDate.month + monthsIncrement, nextDate.day);
    return nextDate;
  }
}