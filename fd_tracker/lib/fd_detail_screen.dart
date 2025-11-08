import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'fd.dart';
import 'fd_provider.dart';
import 'interest_log.dart';
import 'add_fd_screen.dart';

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
      final provider = Provider.of<FDProvider>(context, listen: false);
      provider.fetchFDsAndLogs();

      final daysLeft = _daysRemaining(fdCopy);
      if (daysLeft > 0 &&
          daysLeft <= 7 &&
          fdCopy.status.toLowerCase() == 'active') {
        _showMaturityAlert(context, daysLeft);
      }
    });
  }

  String _fmtDate(DateTime d) => DateFormat('dd MMM yyyy').format(d);

  Widget _buildDetailRow(String label, String value,
      {Color? color, bool isBold = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:',
              style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14
              )),
          Text(
            value,
            style: TextStyle(
              color: color ?? theme.colorScheme.onSurface,
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
    final maturityDayStart =
    DateTime(fd.maturityDate.year, fd.maturityDate.month, fd.maturityDate.day);
    final todayStart = DateTime(now.year, now.month, now.day);
    if (maturityDayStart.isBefore(todayStart)) return 0;
    return maturityDayStart.difference(todayStart).inDays;
  }

  void _showMaturityAlert(BuildContext context, int daysLeft) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Maturity Alert!'),
        content: Text(
            'Your FD "${fdCopy.title}" matures in $daysLeft days on ${_fmtDate(fdCopy.maturityDate)}. Time to plan!'),
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
          content: const Text(
              'No transactional interest is due for the next period based on payout frequency.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    await provider.addInterest(fdCopy.id!, amt,
        note: 'System-calculated credit (${fdCopy.payoutFreq})');

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Interest Credited'),
        content: Text('₹${amt.toStringAsFixed(2)} credited for ${fdCopy.title}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  void _changeStatus(String newStatus) {
    setState(() {
      fdCopy = fdCopy.copyWith(status: newStatus);
    });
    Provider.of<FDProvider>(context, listen: false).updateFD(fdCopy);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status updated to $newStatus')),
    );
  }

  void _openRenewOrEditForm(BuildContext context, {bool isRenewal = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFDScreen(fdToEdit: isRenewal ? null : fdCopy),
      ),
    ).then((_) {
      // Refresh data after edit/renew
      Provider.of<FDProvider>(context, listen: false).fetchFDsAndLogs();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bankCtrl.dispose();
    _principalCtrl.dispose();
    _rateCtrl.dispose();
    _nomineeCtrl.dispose();
    _jointCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<FDProvider>(context);
    final interestLogs = provider.interestLogs[widget.fd.id] ?? [];
    interestLogs.sort((a, b) => b.date.compareTo(a.date));

    final isActive = fdCopy.status.toLowerCase() == 'active';
    final isClosed = fdCopy.status.toLowerCase() == 'closed';
    final isMatured = fdCopy.status.toLowerCase() == 'matured';
    final statusToggleText = isActive ? 'Mark Matured' : 'Re-activate';
    final statusToggleIcon = isActive ? Icons.event_busy : Icons.play_arrow;

    final progress = _computeProgressFraction(fdCopy);
    final daysLeft = _daysRemaining(fdCopy);
    final tenureMonths = fdCopy.getTenureInMonths();
    final nextInterestDate = fdCopy.getNextInterestDate();
    final upcomingInterest = provider.upcomingInterest(fdCopy.id ?? 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(fdCopy.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _openRenewOrEditForm(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Progress
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fdCopy.title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                fdCopy.bankName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Chip(
                          label: Text(fdCopy.status.toUpperCase()),
                          backgroundColor: _getStatusColor(fdCopy.status, theme),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      daysLeft > 0
                          ? '$daysLeft days to maturity'
                          : 'Matured',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Key Metrics
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.account_balance_wallet,
                              color: theme.colorScheme.primary, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            NumberFormat.currency(
                                locale: 'en_IN', symbol: '₹')
                                .format(fdCopy.principal),
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text('Principal', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.trending_up,
                              color: theme.colorScheme.secondary, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            '${fdCopy.rate.toStringAsFixed(2)}%',
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text('Rate p.a.', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Projected Maturity
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Projected Maturity',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                        'Tenure', '${tenureMonths} months', isBold: true),
                    _buildDetailRow(
                        'Expected Amount',
                        NumberFormat.currency(
                            locale: 'en_IN', symbol: '₹')
                            .format(fdCopy.calculateMaturityAmount()),
                        color: theme.colorScheme.primary,
                        isBold: true),
                    if (isActive && upcomingInterest > 0)
                      _buildDetailRow(
                          'Next Interest',
                          '${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(upcomingInterest)} on ${_fmtDate(nextInterestDate)}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Details Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Details', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _buildDetailRow('Start Date', _fmtDate(fdCopy.startDate)),
                    _buildDetailRow('Maturity Date',
                        _fmtDate(fdCopy.maturityDate), color: theme.colorScheme.secondary),
                    _buildDetailRow(
                        'Payout Frequency', fdCopy.payoutFreq),
                    _buildDetailRow('Account No.',
                        fdCopy.accountNo.isNotEmpty
                            ? fdCopy.accountNo
                            : 'N/A'),
                    _buildDetailRow(
                        'Nominee',
                        fdCopy.nomineeName?.isNotEmpty == true
                            ? fdCopy.nomineeName!
                            : 'N/A'),
                    _buildDetailRow(
                        'Joint Holder',
                        fdCopy.jointHolder?.isNotEmpty == true
                            ? fdCopy.jointHolder!
                            : 'None'),
                    _buildDetailRow('TDS',
                        fdCopy.tds != null ? 'Yes (${fdCopy.tds}%)' : 'No'),
                    _buildDetailRow('Remarks',
                        fdCopy.remarks?.isNotEmpty == true
                            ? fdCopy.remarks!
                            : 'None'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Wrap(
              spacing: 12.0,
              runSpacing: 8.0,
              children: [
                ElevatedButton.icon(
                    onPressed: () =>
                        _changeStatus(isClosed ? 'Active' : 'Closed'),
                    icon: Icon(statusToggleIcon),
                    label: Text(statusToggleText)),
                ElevatedButton.icon(
                    onPressed: isActive &&
                        fdCopy.payoutFreq.toLowerCase() != 'on maturity'
                        ? () => _markInterestCredited(context)
                        : null,
                    icon: const Icon(Icons.payment),
                    label: const Text('Mark Interest')),
                ElevatedButton.icon(
                    onPressed:
                    isClosed ? null : () => _openRenewOrEditForm(context, isRenewal: true),
                    icon: const Icon(Icons.replay),
                    label: const Text('Renew FD')),
              ],
            ),

            const SizedBox(height: 20),
            Text('Interest Logs',
                style: Theme.of(context).textTheme.titleLarge),
            const Divider(thickness: 1),

            if (interestLogs.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('No interest payments logged yet.'),
              )
            else
              ...interestLogs
                  .map((l) => Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.monetization_on,
                      color: Colors.green),
                  title: Text('₹${l.amount.toStringAsFixed(2)}',
                      style:
                      const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Credited on ${_fmtDate(l.date)}'),
                  trailing: Text(l.note ?? fdCopy.payoutFreq),
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete Log?'),
                        content:
                        const Text('Delete this interest log entry?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              if (l.id != null) {
                                provider.deleteInterestLog(l.id!);
                              }
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ))
                  .toList(),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'active':
        return theme.colorScheme.primary;
      case 'matured':
      case 'closed':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.outline;
    }
  }
}