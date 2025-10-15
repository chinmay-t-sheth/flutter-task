// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'fd_provider.dart';
import 'fd.dart';
import 'add_fd_screen.dart';
import 'dashboard_screen.dart';
import 'interest_log_screen.dart';
import 'enums.dart'; // Import enums from shared file

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FDSortOption _sortOption = FDSortOption.maturityDate;
  FilterStatus _filterStatus = FilterStatus.active;
  bool _isAscending = true;

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(amount);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FDProvider>(context, listen: false).fetchFDsAndLogs();
    });
  }

  void _showSortFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                runSpacing: 16,
                children: [
                  Text("Filter by Status", style: Theme.of(context).textTheme.titleLarge),
                  SegmentedButton<FilterStatus>(
                    segments: const [
                      ButtonSegment(value: FilterStatus.all, label: Text('All')),
                      ButtonSegment(value: FilterStatus.active, label: Text('Active')),
                      ButtonSegment(value: FilterStatus.matured, label: Text('Matured')),
                    ],
                    selected: {_filterStatus},
                    onSelectionChanged: (Set<FilterStatus> newSelection) {
                      setModalState(() {
                        _filterStatus = newSelection.first;
                      });
                      setState(() {});
                    },
                  ),
                  const Divider(),
                  Text("Sort by", style: Theme.of(context).textTheme.titleLarge),
                  DropdownButtonFormField<FDSortOption>(
                    value: _sortOption,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: FDSortOption.maturityDate, child: Text('Maturity Date')),
                      DropdownMenuItem(value: FDSortOption.principal, child: Text('Principal Amount')),
                      DropdownMenuItem(value: FDSortOption.interestRate, child: Text('Interest Rate')),
                      DropdownMenuItem(value: FDSortOption.creationDate, child: Text('Creation Date')),
                      DropdownMenuItem(value: FDSortOption.bankName, child: Text('Bank Name')),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        _sortOption = value!;
                      });
                      setState(() {});
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Ascending"),
                      Switch(value: _isAscending, onChanged: (value){
                        setModalState(() {
                          _isAscending = value;
                        });
                        setState(() {});
                      }),
                      const Text("Descending"),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My FDs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort & Filter',
            onPressed: _showSortFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.dashboard_rounded),
            tooltip: 'Dashboard',
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()));
            },
          ),
        ],
      ),
      body: Consumer<FDProvider>(
        builder: (context, fdProvider, child) {
          if (fdProvider.fds.isEmpty && fdProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (fdProvider.fds.isEmpty) {
            return const Center(child: Text('No FDs yet. Tap + to add one!'));
          }

          final List<FD> processedFDs = fdProvider.getProcessedFDs(
            filter: _filterStatus,
            sortBy: _sortOption,
            isAscending: _isAscending,
          );

          // Compute filtered totals for the summary card
          final double filteredPrincipal = processedFDs.fold(0.0, (sum, fd) => sum + fd.principal);
          final int fdCount = processedFDs.length;
          final String statusLabel = _filterStatus == FilterStatus.active ? 'Active FDs' : '${_filterStatus.name.capitalize} FDs';

          return Column(
            children: [
              Card(
                color: Theme.of(context).primaryColorLight.withOpacity(0.5),
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const Icon(Icons.wallet, color: Colors.green),
                  title: const Text('Total Invested Principal'),
                  subtitle: Text('$fdCount $statusLabel'),
                  trailing: Text(
                    _formatCurrency(filteredPrincipal),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: processedFDs.length,
                  itemBuilder: (context, index) {
                    final fd = processedFDs[index];
                    return _buildFDExpansionTile(context, fd);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const AddFDScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFDExpansionTile(BuildContext context, FD fd) {
    Color statusColor = fd.status.toLowerCase() == 'matured' ? Colors.red : Colors.green;
    IconData statusIcon = fd.status.toLowerCase() == 'matured' ? Icons.check_circle : Icons.timelapse;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor, size: 24),
        ),
        title: Text(fd.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(fd.bankName),
        trailing: Text(
          _formatCurrency(fd.principal),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                _buildDetailRow('Maturity Value:', _formatCurrency(fd.maturityAmount ?? 0)),
                _buildDetailRow('Maturity Date:', DateFormat('dd MMM yyyy').format(fd.maturityDate)),
                _buildDetailRow('Interest Rate:', '${fd.rate}%'),
                _buildDetailRow('Status:', fd.status, valueColor: statusColor),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.receipt_long, size: 18),
                      label: const Text('Logs'),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => InterestLogScreen(fd: fd)));
                      },
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => AddFDScreen(fdToEdit: fd)));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }
}

// Extension for capitalizing enum names (simple helper)
extension StringExtension on String {
  String get capitalize => this.isEmpty ? this : '${this[0].toUpperCase()}${this.substring(1)}';
}