// lib/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'fd_provider.dart';
import 'fd.dart';
import 'add_fd_screen.dart';
import 'interest_log_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<void> _fetchDataFuture;

  @override
  void initState() {
    super.initState();
    // Defer fetch to after build to avoid notify during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDataFuture = Provider.of<FDProvider>(context, listen: false).fetchFDsAndLogs();
    });
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final fdProvider = Provider.of<FDProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _fetchDataFuture = fdProvider.fetchFDsAndLogs();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _fetchDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (fdProvider.fds.isEmpty) {
            return const Center(
              child: Text(
                'No FDs found.\nTap the + button to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          double totalInvestment = fdProvider.totalPrincipal;
          double activeInvestment = fdProvider.activePrincipal;
          double totalMaturityValue = fdProvider.totalMaturity;
          double totalInterestEarned = totalMaturityValue - totalInvestment;
          double monthlyInterest = fdProvider.getInterestForMonth(DateTime.now());
          int totalFDs = fdProvider.fds.length;
          double avgInterestRate = fdProvider.averageRate;
          double totalInterestReceivedOverall = fdProvider.totalInterestReceived;
          double totalInterestReceivedActive = fdProvider.totalInterestReceivedActive;
          double totalInterestReceivedMatured = fdProvider.totalInterestReceivedMatured;

          List<FD> upcomingMaturities = fdProvider.fds
              .where((fd) =>
          fd.status == 'Active' &&
              fd.maturityDate.isAfter(DateTime.now()) &&
              fd.maturityDate
                  .isBefore(DateTime.now().add(const Duration(days: 30))))
              .toList();

          Map<String, double> bankDistribution = fdProvider.getBankDistribution();
          Map<String, double> interestTrend = fdProvider.getMonthlyInterestTrend();
          List<String> sortedMonths = interestTrend.keys.toList()..sort();

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _fetchDataFuture = fdProvider.fetchFDsAndLogs();
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildSummaryCard(
                          context,
                          'Total Investment',
                          _formatCurrency(totalInvestment),
                          Icons.trending_up,
                          Colors.green,
                        ),
                        _buildSummaryCard(
                          context,
                          'Active Investment',
                          _formatCurrency(activeInvestment),
                          Icons.trending_up,
                          Colors.teal,
                        ),
                        _buildSummaryCard(
                          context,
                          'Total Interest (Est.)',
                          _formatCurrency(totalInterestEarned),
                          Icons.account_balance_wallet,
                          Colors.blue,
                        ),
                        _buildSummaryCard(
                          context,
                          "This Month's Interest",
                          _formatCurrency(monthlyInterest),
                          Icons.calendar_today,
                          Colors.orange,
                        ),
                        _buildSummaryCard(
                          context,
                          'Average Rate',
                          '${avgInterestRate.toStringAsFixed(2)}%',
                          Icons.show_chart,
                          Colors.purple,
                        ),
                        _buildSummaryCard(
                          context,
                          'Total Received (Overall)',
                          _formatCurrency(totalInterestReceivedOverall),
                          Icons.receipt_long,
                          Colors.indigo,
                        ),
                        _buildSummaryCard(
                          context,
                          'Received (Active FDs)',
                          _formatCurrency(totalInterestReceivedActive),
                          Icons.check_circle,
                          Colors.green,
                        ),
                        _buildSummaryCard(
                          context,
                          'Received (Matured FDs)',
                          _formatCurrency(totalInterestReceivedMatured),
                          Icons.history,
                          Colors.red,
                        ),
                        _buildSummaryCard(
                          context,
                          'Total FDs',
                          '$totalFDs',
                          Icons.list_alt,
                          Colors.teal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (upcomingMaturities.isNotEmpty) ...[
                      _buildSectionTitle(context, 'Upcoming Maturities (30 Days)'),
                      const SizedBox(height: 10),
                      ...upcomingMaturities.map((fd) => _buildMaturityTile(fd)),
                      const SizedBox(height: 20),
                    ],

                    if (bankDistribution.isNotEmpty) ...[
                      _buildSectionTitle(context, 'Distribution by Bank'),
                      const SizedBox(height: 10),
                      _buildChartCard(
                        height: 250,
                        child: PieChart(
                          PieChartData(
                            sections: _generatePieSections(bankDistribution, totalInvestment),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    _buildSectionTitle(context, 'Interest Trend (Last 6 Months)'),
                    const SizedBox(height: 10),
                    _buildChartCard(
                      height: 200,
                      child: LineChart(
                        _buildInterestTrendData(interestTrend, sortedMonths),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildSectionTitle(context, 'All FDs'),
                    const SizedBox(height: 10),
                    ...fdProvider.fds.map((fd) => _buildFDExpansionTile(context, fd)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildMaturityTile(FD fd) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.event, color: Colors.orange),
        title: Text(fd.title),
        subtitle: Text('${fd.bankName} • ${DateFormat('dd MMM').format(fd.maturityDate)}'),
        trailing: Text(_formatCurrency(fd.maturityAmount ?? 0)),
      ),
    );
  }

  Widget _buildChartCard({required double height, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections(Map<String, double> data, double total) {
    final colors = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red, Colors.teal
    ];
    int colorIndex = 0;
    return data.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final color = colors[colorIndex++ % colors.length];
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: Text(entry.key, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        badgePositionPercentageOffset: 1.2,
      );
    }).toList();
  }

  LineChartData _buildInterestTrendData(Map<String, double> trendData, List<String> sortedMonths) {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < sortedMonths.length) {
                final date = DateFormat('yyyy-MM').parse(sortedMonths[index]);
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    DateFormat('MMM').format(date),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: sortedMonths.asMap().entries.map((entry) {
            final monthKey = entry.value;
            final y = trendData[monthKey] ?? 0;
            return FlSpot(entry.key.toDouble(), y);
          }).toList(),
          isCurved: true,
          color: Colors.green,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.green.withOpacity(0.2),
          ),
        ),
      ],
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