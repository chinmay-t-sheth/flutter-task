import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'fd_provider.dart';
import 'interest_log.dart';
import 'fd.dart';

class AllInterestLogsScreen extends StatelessWidget {
  const AllInterestLogsScreen({super.key});

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Interest Logs'),
      ),
      body: Consumer<FDProvider>(
        builder: (context, fdProvider, child) {
          // Get all interest logs from all FDs
          final allLogs = <InterestLog>[];
          fdProvider.interestLogs.forEach((fdId, logs) {
            allLogs.addAll(logs);
          });

          // Sort by date (newest first)
          allLogs.sort((a, b) => b.date.compareTo(a.date));

          // Get FD details for each log
          FD? getFD(dynamic fdId) {
            try {
              final fdIdStr = fdId.toString();
              return fdProvider.fds.firstWhere(
                    (fd) => fd.id.toString() == fdIdStr,
              );
            } catch (e) {
              return null;
            }
          }

          if (allLogs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No Interest Logs Found'),
                  SizedBox(height: 8),
                  Text('Interest payments will appear here',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // Calculate total interest
          final totalInterest = allLogs.fold(0.0, (sum, log) => sum + log.amount);

          return Column(
            children: [
              // Summary card
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              _formatCurrency(totalInterest),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Text('Total Interest Received'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              allLogs.length.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('Total Entries'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: allLogs.length,
                  itemBuilder: (context, index) {
                    final log = allLogs[index];
                    final fd = getFD(log.fdId);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Icon(Icons.monetization_on, color: Colors.green.shade800),
                        ),
                        title: Text(
                          _formatCurrency(log.amount),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Fixed if-else syntax using conditional operator
                            fd != null
                                ? Text(
                              '${fd.title} • ${fd.bankName}',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            )
                                : Text(
                              'FD Not Found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Text(DateFormat('dd MMM yyyy').format(log.date)),
                            if (log.note != null && log.note!.isNotEmpty)
                              Text(
                                'Note: ${log.note!}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: Text(
                          DateFormat('MMM yy').format(log.date),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}