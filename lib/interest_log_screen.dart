import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'fd_provider.dart';
import 'fd.dart';
import 'interest_log.dart';

class InterestLogScreen extends StatefulWidget {
  final FD fd;
  const InterestLogScreen({super.key, required this.fd});

  @override
  State<InterestLogScreen> createState() => _InterestLogScreenState();
}

class _InterestLogScreenState extends State<InterestLogScreen> {
  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.fd.title} - Interest Logs'),
        actions: [
          if (widget.fd.status.toLowerCase() == 'active')
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddManualLogDialog(context),
            ),
        ],
      ),
      body: Consumer<FDProvider>(
        builder: (context, fdProvider, child) {
          final logs = fdProvider.interestLogs[widget.fd.id] ?? [];
          logs.sort((a, b) => b.date.compareTo(a.date)); // Latest first

          return Column(
            children: [
              // Summary Cards
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Icon(Icons.monetization_on, color: Colors.green, size: 32),
                              Text(_formatCurrency(logs.fold(0.0, (sum, log) => sum + log.amount)), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const Text('Total Received'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Icon(Icons.schedule, color: Colors.orange, size: 32),
                              Text('${logs.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const Text('Entries'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  children: [
                    if (widget.fd.status.toLowerCase() == 'active')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add_task),
                          label: const Text('Mark Next Interest as Received'),
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12)),
                          onPressed: () =>
                              _markUpcomingInterestAsReceived(context),
                        ),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit_calendar),
                        label: const Text('Add a Manual/Past Entry'),
                        onPressed: () => _showAddManualLogDialog(context),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 20, indent: 12, endIndent: 12),

              Expanded(
                child: logs.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return Dismissible(
                      key: ValueKey(log.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _deleteLog(log),
                      background: Container(
                        color: Colors.red.shade700,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete,
                            color: Colors.white),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text((index + 1).toString()),
                        ),
                        title: Text(
                          _formatCurrency(log.amount),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            '${DateFormat('dd MMM yyyy').format(log.date)} ${log.note != null && log.note!.isNotEmpty ? '• ${log.note}' : ''}'),
                      ),
                    );
                  },
                ),
              ),

              if (widget.fd.status.toLowerCase() == 'matured')
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () => _showReinvestmentSimulation(context),
                    child: const Text('Simulate Reinvestment'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _markUpcomingInterestAsReceived(BuildContext context) {
    final fdProvider = Provider.of<FDProvider>(context, listen: false);
    final upcomingAmount = fdProvider.upcomingInterest(widget.fd.id!);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Interest Received'),
        content: Text(
            'Do you want to add ${_formatCurrency(upcomingAmount)} to the interest log for ${widget.fd.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              fdProvider.addInterest(widget.fd.id!, upcomingAmount);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        '${_formatCurrency(upcomingAmount)} logged successfully!')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showAddManualLogDialog(BuildContext context) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Manual Log'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Interest Amount',
                  prefixText: '₹',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(val) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note (Optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final amount = double.parse(amountController.text);
                final note = noteController.text;
                Provider.of<FDProvider>(context, listen: false)
                    .addInterest(widget.fd.id!, amount, note: note);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteLog(InterestLog log) {
    final fdProvider = Provider.of<FDProvider>(context, listen: false);
    fdProvider.deleteInterestLog(log.id!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Log entry deleted.'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            fdProvider.addInterestWithDate(log.fdId, log.amount,
                note: log.note, date: log.date);
          },
        ),
      ),
    );
  }

  void _showReinvestmentSimulation(BuildContext context) {
    double maturityAmount = widget.fd.maturityAmount ?? 0;
    double newRate = widget.fd.rate;
    int tenureMonths = widget.fd.getTenureInMonths();
    double t = tenureMonths / 12.0;
    int n = 4;

    double simulatedAmount =
        maturityAmount * pow((1 + (newRate / 100) / n), n * t);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reinvestment Simulation"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Maturity: ${_formatCurrency(maturityAmount)}'),
            Text('Reinvest at ${newRate}% for ${tenureMonths} months'),
            const Divider(),
            Text('Projected Amount: ${_formatCurrency(simulatedAmount)}'),
            Text('Additional Interest: ${_formatCurrency(simulatedAmount - maturityAmount)}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/empty_log.json',
              height: 200,
              repeat: true,
            ),
            const SizedBox(height: 20),
            const Text(
              'No Interest Logged Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'Use the buttons above to log interest received from this FD.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}