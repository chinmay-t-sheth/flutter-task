// lib/fd_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'fd.dart';
import 'fd_provider.dart';
import 'interest_log.dart';

class FDDetailScreen extends StatefulWidget {
  final FD fd;
  const FDDetailScreen({super.key, required this.fd});

  @override
  State<FDDetailScreen> createState() => _FDDetailScreenState();
}

class _FDDetailScreenState extends State<FDDetailScreen> {
  late FD fdCopy;
  final _titleCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _principalCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _nomineeCtrl = TextEditingController();
  final _jointCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fdCopy = FD.fromMap(widget.fd.toMap());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final daysLeft = _daysRemaining(fdCopy);
      if (daysLeft > 0 && daysLeft <= 7 && fdCopy.status.toLowerCase() == 'active') {
        _showMaturityAlert(context, daysLeft);
      }
    });
  }

  String _fmtDate(DateTime d) => DateFormat('dd MMM yyyy').format(d);

  Widget _buildDetailRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  double _computeProgressFraction(FD fd) {
    final now = DateTime.now();
    if (fd.maturityDate.isBefore(fd.startDate)) return 1.0;
    final totalDays = fd.maturityDate.difference(fd.startDate).inDays;
    if (totalDays <= 0) return 1.0;
    final elapsed = now.isBefore(fd.startDate)
        ? 0
        : (now.isAfter(fd.maturityDate)
        ? totalDays
        : now.difference(fd.startDate).inDays);
    return elapsed / totalDays.clamp(1, totalDays);
  }

  int _daysRemaining(FD fd) {
    final now = DateTime.now();
    final maturityDayStart = DateTime(fd.maturityDate.year, fd.maturityDate.month, fd.maturityDate.day);
    final todayStart = DateTime(now.year, now.month, now.day);
    if (maturityDayStart.isBefore(todayStart)) return 0;
    return maturityDayStart.difference(todayStart).inDays;
  }

  void _showMaturityAlert(BuildContext context, int daysLeft) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Maturity Alert!'),
        content: Text('Your FD "${fdCopy.title}" matures in $daysLeft days on ${_fmtDate(fdCopy.maturityDate)}. Time to plan!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _markInterestCredited(BuildContext context) async {
    final provider = Provider.of<FDProvider>(context, listen: false);
    if (fdCopy.id == null) return;

    final amt = provider.upcomingInterest(fdCopy.id!);

    if (amt <= 0) {
      if (!mounted) return;
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
              title: const Text('No Interest Due'),
              content: const Text('No transactional interest is due for the next period based on payout frequency.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
              ]));
      return;
    }

    await provider.addInterest(fdCopy.id!, amt, note: 'System-calculated credit (${fdCopy.payoutFreq})');

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Interest Credited'),
        content: Text('₹${amt.toStringAsFixed(2)} credited for ${fdCopy.title}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _changeStatus(String newStatus) async {
    final provider = Provider.of<FDProvider>(context, listen: false);

    fdCopy.status = newStatus;
    await provider.updateFD(fdCopy);
  }

  Future<void> _openRenewOrEditForm(BuildContext context, {required bool isRenewal}) async {
    _titleCtrl.text = fdCopy.title;
    _bankCtrl.text = fdCopy.bankName;
    _principalCtrl.text = (isRenewal ? (fdCopy.maturityAmount ?? 0) : fdCopy.principal).toString();
    _rateCtrl.text = fdCopy.rate.toString();
    _nomineeCtrl.text = fdCopy.nomineeName ?? '';
    _jointCtrl.text = fdCopy.jointHolder ?? '';
    _remarksCtrl.text = fdCopy.remarks ?? '';

    DateTime start = isRenewal ? DateTime.now() : fdCopy.startDate;
    DateTime maturity = fdCopy.maturityDate;
    String comp = fdCopy.compounding;
    String payout = fdCopy.payoutFreq;

    FD tempFD = FD.fromMap(fdCopy.toMap());
    tempFD.maturityAmount = tempFD.calculateMaturityAmount();

    void _updateMaturityPreview({required double principal, required double rate, required DateTime startDate, required DateTime maturityDate, required String compounding}) {
      tempFD.principal = principal;
      tempFD.rate = rate;
      tempFD.startDate = startDate;
      tempFD.maturityDate = maturityDate;
      tempFD.compounding = compounding;
      tempFD.maturityAmount = tempFD.calculateMaturityAmount();
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Text(isRenewal ? 'Renew FD' : 'Edit FD'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextFormField(
                    controller: _bankCtrl,
                    decoration: const InputDecoration(labelText: 'Bank'),
                  ),
                  TextFormField(
                    controller: _principalCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Principal'),
                    onChanged: (val) {
                      final p = double.tryParse(val) ?? 0;
                      setModalState(() {
                        _updateMaturityPreview(
                          principal: p,
                          rate: double.tryParse(_rateCtrl.text) ?? 0,
                          startDate: start,
                          maturityDate: maturity,
                          compounding: comp,
                        );
                      });
                    },
                  ),
                  TextFormField(
                    controller: _rateCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Rate (%)'),
                    onChanged: (val) {
                      final r = double.tryParse(val) ?? 0;
                      setModalState(() {
                        _updateMaturityPreview(
                          principal: double.tryParse(_principalCtrl.text) ?? 0,
                          rate: r,
                          startDate: start,
                          maturityDate: maturity,
                          compounding: comp,
                        );
                      });
                    },
                  ),
                  Text('Estimated Maturity: ₹${tempFD.maturityAmount?.toStringAsFixed(2) ?? '0'}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final updatedFD = FD(
                    id: fdCopy.id,
                    title: _titleCtrl.text,
                    bankName: _bankCtrl.text,
                    principal: double.tryParse(_principalCtrl.text) ?? 0,
                    rate: double.tryParse(_rateCtrl.text) ?? 0,
                    startDate: start,
                    maturityDate: maturity,
                    compounding: comp,
                    payoutFreq: payout,
                    nomineeName: _nomineeCtrl.text,
                    jointHolder: _jointCtrl.text,
                    remarks: _remarksCtrl.text,
                    status: fdCopy.status,
                  );
                  final provider = Provider.of<FDProvider>(context, listen: false);
                  await provider.updateFD(updatedFD);
                  Navigator.pop(context);
                  if (mounted) {
                    setState(() {
                      fdCopy = updatedFD;
                    });
                  }
                },
                child: Text(isRenewal ? 'Renew' : 'Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FDProvider>(context);
    final interestLogs = provider.getLogsForFD(widget.fd.id!);
    final isActive = fdCopy.status.toLowerCase() == 'active';
    final isMatured = fdCopy.status.toLowerCase() == 'matured';
    final isClosed = fdCopy.status.toLowerCase() == 'closed';
    final progress = _computeProgressFraction(fdCopy);
    final daysLeft = _daysRemaining(fdCopy);
    final statusToggleText = isClosed ? 'Reopen' : 'Close';
    final statusToggleIcon = isClosed ? Icons.lock_open : Icons.lock;

    return Scaffold(
      appBar: AppBar(
        title: Text(fdCopy.title),
        actions: [
          IconButton(
              onPressed: () => _openRenewOrEditForm(context, isRenewal: false),
              icon: const Icon(Icons.edit)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Current Status', fdCopy.status,
                        color: isActive ? Colors.green : (isMatured ? Colors.orange : Colors.red), isBold: true),
                    const Divider(),
                    _buildDetailRow('Principal', '₹${fdCopy.principal.toStringAsFixed(0)}'),
                    _buildDetailRow('Rate', '${fdCopy.rate}%'),
                    _buildDetailRow('Maturity Amount', '₹${fdCopy.maturityAmount?.toStringAsFixed(0) ?? 'N/A'}', isBold: true),

                    const SizedBox(height: 10),
                    Text('Progress: ${(progress * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w500)),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(isActive ? Colors.indigo : Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Text(daysLeft > 0 ? 'Matures in $daysLeft days' : 'Matured', style: TextStyle(fontSize: 12, color: daysLeft > 30 ? Colors.grey : Colors.red)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Start Date', _fmtDate(fdCopy.startDate)),
                    _buildDetailRow('Maturity Date', _fmtDate(fdCopy.maturityDate), isBold: true),
                    _buildDetailRow('Compounding', fdCopy.compounding),
                    _buildDetailRow('Payout Frequency', fdCopy.payoutFreq),
                    _buildDetailRow('Next Interest Date', _fmtDate(fdCopy.getNextInterestDate())),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Additional Details', style: Theme.of(context).textTheme.titleMedium),
                    const Divider(),
                    _buildDetailRow('Bank Name', fdCopy.bankName),
                    _buildDetailRow('Account No.', fdCopy.accountNo.isNotEmpty ? fdCopy.accountNo : 'N/A'),
                    _buildDetailRow('Nominee', fdCopy.nomineeName?.isNotEmpty == true ? fdCopy.nomineeName! : 'N/A'),
                    _buildDetailRow('Joint Holder', fdCopy.jointHolder?.isNotEmpty == true ? fdCopy.jointHolder! : 'None'),
                    _buildDetailRow('TDS', fdCopy.tds != null ? 'Yes (${fdCopy.tds}%)' : 'No'),
                    _buildDetailRow('Remarks', fdCopy.remarks?.isNotEmpty == true ? fdCopy.remarks! : 'None'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 12.0,
              runSpacing: 8.0,
              children: [
                ElevatedButton.icon(
                    onPressed: () => _changeStatus(isClosed ? 'Active' : 'Closed'),
                    icon: Icon(statusToggleIcon),
                    label: Text(statusToggleText)),

                ElevatedButton.icon(
                    onPressed: isActive && fdCopy.payoutFreq.toLowerCase() != 'on maturity' ? () => _markInterestCredited(context) : null,
                    icon: const Icon(Icons.payment),
                    label: const Text('Mark Interest')),

                ElevatedButton.icon(
                    onPressed: isClosed ? null : () => _openRenewOrEditForm(context, isRenewal: true),
                    icon: const Icon(Icons.replay),
                    label: const Text('Renew FD')),
              ],
            ),

            const SizedBox(height: 20),
            Text('Interest Logs', style: Theme.of(context).textTheme.titleLarge),
            const Divider(thickness: 1),

            if (interestLogs.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('No interest payments logged yet.'),
              )
            else
              ...interestLogs.map((l) => Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.monetization_on, color: Colors.green),
                  title: Text('₹${l.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Credited on ${_fmtDate(l.date)}'),
                  trailing: Text(l.note ?? fdCopy.payoutFreq),
                ),
              )).toList(),
          ],
        ),
      ),
    );
  }
}