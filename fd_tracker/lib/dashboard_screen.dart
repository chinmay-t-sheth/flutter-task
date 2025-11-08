// lib/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'fd_provider.dart';
import 'fd.dart';
import 'add_fd_screen.dart';
import 'fd_detail_screen.dart';
import 'settings_screen.dart';
import 'enums.dart';
import 'all_interest_logs_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late AnimationController _floatingActionController;
  late Animation<double> _floatingActionAnimation;
  late List<Animation<double>> _cardAnims;

  FDSortOption _sortOption = FDSortOption.maturityDate;
  FilterStatus _filterStatus = FilterStatus.all;
  bool _isAscending = true;
  final TextEditingController _searchController = TextEditingController();

  // Scroll controller for parallax effects
  final ScrollController _scrollController = ScrollController();
  final double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();

    _staggerController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200)
    );

    _floatingActionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _floatingActionAnimation = CurvedAnimation(
      parent: _floatingActionController,
      curve: Curves.elasticOut,
    );

    _cardAnims = List.generate(8, (i) {
      final start = i * 0.06;
      final end = (i * 0.06) + 0.5;
      return Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(
            start.clamp(0.0, 1.0),
            end.clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    _staggerController.forward();
    _floatingActionController.forward();

    // Add this to prevent overflow
    _staggerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _staggerController.stop();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<FDProvider>(context, listen: false);
      provider.fetchFDsAndLogs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _staggerController.dispose();
    _floatingActionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(amount);
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'matured':
        return theme.colorScheme.secondary;
      default:
        return theme.colorScheme.outline;
    }
  }

  Color _stringToColor(String s) {
    const palette = [
      Color(0xFF6366F1),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6),
      Color(0xFF06B6D4),
      Color(0xFF84CC16),
      Color(0xFFF97316),
    ];
    return palette[s.hashCode.abs() % palette.length];
  }

  // ADD THIS MISSING METHOD
  void _showUpcomingDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const UpcomingInterestSheet(),
    );
  }

  Widget _buildAnimatedBackground(ThemeData theme) {
    return Transform.translate(
      offset: Offset(0, -_scrollOffset * 0.3),
      child: Container(
        height: 280 + _scrollOffset * 0.3,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withAlpha(25),
              theme.colorScheme.primary.withAlpha(12),
              Colors.transparent,
            ],
          ),
        ),
        child: CustomPaint(
          painter: _BackgroundPainter(),
        ),
      ),
    );
  }

  Widget _heroHeader(ThemeData theme, double totalInvestment, double totalInterest) {
    return AnimatedBuilder(
      animation: _cardAnims[0],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _cardAnims[0].value) * 50),
          child: Opacity(
            opacity: _cardAnims[0].value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withAlpha(230),
                    theme.colorScheme.primary.withAlpha(178),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(76),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(51),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Text('Portfolio Overview',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('Total Invested',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withAlpha(204),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(_formatCurrency(totalInvestment),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(38),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.trending_up, size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              Text('Total Interest: ${_formatCurrency(totalInterest)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, int index, String title, String value, IconData icon, Color color, {String? subtitle}) {
    return AnimatedBuilder(
      animation: _cardAnims[index],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _cardAnims[index].value) * 30),
          child: Opacity(
            opacity: _cardAnims[index].value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _cardAnims[index].value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withAlpha(25),
                      color.withAlpha(12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withAlpha(51)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: color, size: 20),
                          ),
                          if (subtitle != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(subtitle,
                                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(title,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(value,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _statGrid(BuildContext context, ThemeData theme, double activeInvestment, double monthlyInterest, double avgRate, int totalFDs, double activeInterest, double maturedInterest, double portfolioYield, double healthScore) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(context, 0, 'Active Investment', _formatCurrency(activeInvestment), Icons.account_balance, Colors.blue),
        _buildStatCard(context, 1, 'Avg. Rate', '${avgRate.toStringAsFixed(1)}%', Icons.trending_up, Colors.green),
        _buildStatCard(context, 2, 'Total Active FDs', totalFDs.toString(), Icons.list_alt, Colors.purple),
        _buildStatCard(context, 3, 'Monthly Interest', _formatCurrency(monthlyInterest), Icons.schedule, Colors.orange),
        _buildStatCard(context, 4, 'Active Interest', _formatCurrency(activeInterest), Icons.payment, Colors.teal, subtitle: 'RECEIVED'),
        _buildStatCard(context, 5, 'Matured Interest', _formatCurrency(maturedInterest), Icons.history, Colors.brown, subtitle: 'RECEIVED'),
        _buildStatCard(context, 6, 'Portfolio Yield', '${portfolioYield.toStringAsFixed(1)}%', Icons.analytics, Colors.indigo),
        _buildStatCard(context, 7, 'Health Score', '${healthScore.toStringAsFixed(0)}%', Icons.favorite, Colors.pink),
      ],
    );
  }

  Widget _upcomingCard(double upcoming, ThemeData theme) {
    if (upcoming <= 0) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _cardAnims[3],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _cardAnims[3].value) * 30),
          child: Opacity(
              opacity: _cardAnims[3].value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.orange.withAlpha(25),
                      Colors.orange.withAlpha(12),
                    ]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withAlpha(76)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.notifications_active, color: Colors.orange, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Upcoming Interest',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('₹${upcoming.toStringAsFixed(2)} due soon',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(178),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _showUpcomingDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('View'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _pieSection(List<FD> allFDs, ThemeData theme) {
    // Filter only active FDs
    final activeFDs = allFDs.where((fd) => fd.status.toLowerCase() == 'active').toList();

    if (activeFDs.isEmpty) return const SizedBox.shrink();

    final Map<String, double> pieData = <String, double>{};
    for (var fd in activeFDs) {
      pieData[fd.bankName] = (pieData[fd.bankName] ?? 0) + fd.principal;
    }

    if (pieData.values.fold(0.0, (a, b) => a + b) == 0) return const SizedBox.shrink();

    final normalized = _normalizePercent(pieData);
    final sections = normalized.entries.map((e) {
      final color = _stringToColor(e.key);
      return PieChartSectionData(
        color: color,
        value: e.value,
        title: e.value > 5 ? '${e.value.toStringAsFixed(0)}%' : '',
        radius: 24,
        titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
        badgeWidget: e.value <= 5 ? Text('${e.value.toStringAsFixed(0)}%',
          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
        ) : null,
        badgePositionPercentageOffset: 0.6,
      );
    }).toList();

    return AnimatedBuilder(
      animation: _cardAnims[4],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _cardAnims[4].value) * 30),
          child: Opacity(
            opacity: _cardAnims[4].value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.pie_chart, color: theme.colorScheme.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text('Active FD Distribution', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Distribution by Bank (Active FDs only)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 180,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: PieChart(
                              PieChartData(
                                sections: sections,
                                centerSpaceRadius: 40,
                                sectionsSpace: 2,
                                borderData: FlBorderData(show: false),
                                startDegreeOffset: -90,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: normalized.entries.map((e) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _stringToColor(e.key),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(e.key,
                                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text('${e.value.toStringAsFixed(1)}%',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              )).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _fdListSection(List<FD> filteredList, ThemeData theme) {
    if (filteredList.isEmpty) {
      return AnimatedBuilder(
        animation: _cardAnims[5],
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, (1 - _cardAnims[5].value) * 30),
            child: Opacity(
              opacity: _cardAnims[5].value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: theme.colorScheme.surface,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 80, color: theme.colorScheme.onSurface.withAlpha(76)),
                      const SizedBox(height: 16),
                      Text('No FDs Found', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Add your first Fixed Deposit to start tracking',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFDScreen())),
                        icon: const Icon(Icons.add),
                        label: const Text('Add First FD'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 500),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(
              child: widget,
            ),
          ),
          children: filteredList.map((fd) {
            final daysLeft = fd.maturityDate.difference(DateTime.now()).inDays;
            final isSoon = daysLeft > 0 && daysLeft <= 30;
            final isOverdue = daysLeft < 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withAlpha(25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FDDetailScreen(fd: fd))),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _getStatusColor(fd.status, theme).withAlpha(51),
                                _getStatusColor(fd.status, theme).withAlpha(25),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_getStatusIcon(fd.status),
                            color: _getStatusColor(fd.status, theme),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fd.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(fd.bankName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withAlpha(153),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('${_formatCurrency(fd.principal)} @ ${fd.rate}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_formatCurrency(fd.maturityAmount ?? 0),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (isSoon)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.orange, Colors.orange.shade400],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('$daysLeft days',
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              )
                            else if (isOverdue)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withAlpha(25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text('Overdue',
                                  style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withAlpha(25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('Active',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active': return Icons.play_arrow_rounded;
      case 'matured': return Icons.check_circle_rounded;
      default: return Icons.help_outline_rounded;
    }
  }

  void _showSortFilterSheet() {
    FilterStatus localFilterStatus = _filterStatus;
    FDSortOption localSortOption = _sortOption;
    bool localIsAscending = _isAscending;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onSurface.withAlpha(51),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Sort & Filter',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Organize your FD portfolio',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Filter by Status',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          SegmentedButton<FilterStatus>(
                            segments: const [
                              ButtonSegment(value: FilterStatus.all, label: Text('All')),
                              ButtonSegment(value: FilterStatus.active, label: Text('Active')),
                              ButtonSegment(value: FilterStatus.matured, label: Text('Matured')),
                            ],
                            selected: {localFilterStatus},
                            onSelectionChanged: (Set<FilterStatus> newSelection) {
                              setModalState(() {
                                localFilterStatus = newSelection.first;
                              });
                            },
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Sort by',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Theme.of(context).colorScheme.outline.withAlpha(51)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<FDSortOption>(
                                value: localSortOption,
                                isExpanded: true,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                items: const [
                                  DropdownMenuItem(value: FDSortOption.maturityDate, child: Text('Maturity Date')),
                                  DropdownMenuItem(value: FDSortOption.principal, child: Text('Principal Amount')),
                                  DropdownMenuItem(value: FDSortOption.interestRate, child: Text('Interest Rate')),
                                  DropdownMenuItem(value: FDSortOption.creationDate, child: Text('Creation Date')),
                                  DropdownMenuItem(value: FDSortOption.bankName, child: Text('Bank Name')),
                                ],
                                onChanged: (value) {
                                  setModalState(() {
                                    localSortOption = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(76),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Sort Order', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                  Switch(
                                    value: localIsAscending,
                                    onChanged: (value) {
                                      setModalState(() {
                                        localIsAscending = value;
                                      });
                                    },
                                    activeColor: Theme.of(context).colorScheme.primary,
                                  ),
                                  Text(localIsAscending ? 'Ascending' : 'Descending',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _filterStatus = localFilterStatus;
                                  _sortOption = localSortOption;
                                  _isAscending = localIsAscending;
                                });
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                // Hero header shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Stats grid shimmer
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: List.generate(8, (index) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      height: 100,
                    ),
                  )),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search, color: theme.colorScheme.primary, size: 20),
            ),
            onPressed: () {
              showSearch(
                context: context,
                delegate: DashboardSearchDelegate(Provider.of<FDProvider>(context, listen: false).fds, _formatCurrency),
              );
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.more_vert, color: theme.colorScheme.primary, size: 20),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withAlpha(51),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildMenuOption(Icons.add, 'Add New FD', () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFDScreen()));
                        }, theme),
                        _buildMenuOption(Icons.settings, 'Settings', () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                        }, theme),
                        _buildMenuOption(Icons.analytics, 'Interest Logs', () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AllInterestLogsScreen()));
                        }, theme),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<FDProvider>(
        builder: (context, fdProvider, child) {
          if (fdProvider.isLoading) {
            return _buildLoadingState();
          }

          final now = DateTime.now();
          final double totalInvestment = fdProvider.totalPrincipal;
          final double activeInvestment = fdProvider.activePrincipal;
          final double totalInterest = fdProvider.totalInterestReceived;
          final double avgRate = fdProvider.averageRate;
          final int activeFDsCount = fdProvider.fds.where((fd) => fd.status.toLowerCase() == 'active').length;          final double monthlyInterest = fdProvider.getInterestForMonth(DateTime(now.year, now.month, 1));
          final double upcoming = fdProvider.totalUpcomingInterest;
          final double activeInterest = fdProvider.totalInterestReceivedActive;
          final double maturedInterest = fdProvider.totalInterestReceivedMatured;
          final double portfolioYield = fdProvider.portfolioYield;
          final double healthScore = fdProvider.healthScore;

          final Map<String, double> pieData = <String, double>{};
          for (var fd in fdProvider.fds) {
            pieData[fd.bankName] = (pieData[fd.bankName] ?? 0) + fd.principal;
          }

          final filteredList = fdProvider.getFilteredAndSortedFDs(filter: _filterStatus, sortBy: _sortOption, ascending: _isAscending);

          return Stack(
            children: [
              _buildAnimatedBackground(theme),
              RefreshIndicator(
                onRefresh: () => fdProvider.fetchFDsAndLogs(),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          children: [
                            _heroHeader(theme, totalInvestment, totalInterest),
                            const SizedBox(height: 20),
                            _statGrid(context, theme, activeInvestment, monthlyInterest, avgRate, activeFDsCount, activeInterest, maturedInterest, portfolioYield, healthScore),                            const SizedBox(height: 20),
                            _upcomingCard(upcoming, theme),
                            const SizedBox(height: 20),
                            _pieSection(fdProvider.fds, theme),
                            const SizedBox(height: 24),
                            // Section header
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Your FDs (${filteredList.length})',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _showSortFilterSheet,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withAlpha(25),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.sort, size: 16, color: theme.colorScheme.primary),
                                          const SizedBox(width: 6),
                                          Text('Sort & Filter',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // FD list
                            _fdListSection(filteredList, theme),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _floatingActionAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _floatingActionAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _scrollOffset > 100 ? 100 : 0),
              child: Opacity(
                opacity: _scrollOffset > 100 ? 0.0 : 1.0,
                child: FloatingActionButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFDScreen())),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.add, size: 24),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String text, VoidCallback onTap, ThemeData theme) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(text, style: theme.textTheme.bodyLarge),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.colorScheme.onSurface.withAlpha(128)),
      onTap: onTap,
    );
  }

  Map<String, double> _normalizePercent(Map<String, double> raw) {
    final total = raw.values.fold<double>(0.0, (a, b) => a + b);
    if (total <= 0) {
      return Map.fromEntries(raw.keys.map((k) => MapEntry(k, 0.0)));
    }
    return Map.fromEntries(raw.entries.map((e) => MapEntry(e.key, (e.value / total) * 100)));
  }
}

class DashboardSearchDelegate extends SearchDelegate {
  final List<FD> fds;
  final String Function(double) formatCurrency;

  DashboardSearchDelegate(this.fds, this.formatCurrency);

  List<FD> _filterFDs(List<FD> fds, String query) {
    if (query.isEmpty) return fds;
    return fds.where((fd) =>
    fd.title.toLowerCase().contains(query.toLowerCase()) ||
        fd.bankName.toLowerCase().contains(query.toLowerCase()) ||
        fd.rate.toString().contains(query)
    ).toList();
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
    AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: query.isEmpty
          ? const SizedBox.shrink()
          : IconButton(
        icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.primary),
        onPressed: () => query = '',
      ),
    ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.primary),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
    final results = _filterFDs(fds, query);
    final theme = Theme.of(context);

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 80, color: theme.colorScheme.onSurface.withAlpha(76)),
            const SizedBox(height: 16),
            Text('No results for "$query"', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Try different keywords', style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            )),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (ctx, i) {
          final fd = results[i];
          return AnimationConfiguration.staggeredList(
            position: i,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withAlpha(25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.account_balance, color: theme.colorScheme.primary),
                    ),
                    title: Text(fd.title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    subtitle: Text(fd.bankName, style: theme.textTheme.bodySmall),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(formatCurrency(fd.principal), style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${fd.rate}%', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    onTap: () => close(context, fd),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withAlpha(128)),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
    );
  }
}

class UpcomingInterestSheet extends StatelessWidget {
  const UpcomingInterestSheet({super.key});

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Consumer<FDProvider>(
        builder: (context, provider, child) {
          final upcomingEntries = <MapEntry<DateTime, Widget>>[];
          for (var fd in provider.fds) {
            if (fd.id != null && fd.status.toLowerCase() == 'active') {
              final nextDate = fd.getNextInterestDate();
              final amt = provider.upcomingInterest(fd.id!);
              if (amt > 0) {
                upcomingEntries.add(
                  MapEntry(
                    nextDate,
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: theme.colorScheme.surfaceContainerHighest.withAlpha(76),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.payment, color: Colors.green),
                        ),
                        title: Text(fd.title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Text('${_formatCurrency(amt)} on ${DateFormat('dd MMM yyyy').format(nextDate)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        trailing: Text(_formatCurrency(amt),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            }
          }
          upcomingEntries.sort((a, b) => a.key.compareTo(b.key));
          final upcomingLogs = upcomingEntries.map((e) => e.value).toList();

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withAlpha(51),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_active, color: Colors.orange, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text('Upcoming Interest Payments',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Scheduled interest payments for your active FDs',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                ),
                const SizedBox(height: 24),
                if (upcomingLogs.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: theme.colorScheme.surfaceContainerHighest.withAlpha(76),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.schedule, size: 48, color: theme.colorScheme.onSurface.withAlpha(76)),
                        const SizedBox(height: 12),
                        Text('No Upcoming Payments', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('All caught up! No interest payments due soon.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(153),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...upcomingLogs,
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blue.withAlpha(7),
          Colors.purple.withAlpha(7),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw some subtle background shapes
    final path = Path()
      ..moveTo(size.width * 0.7, 0)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.3, size.width * 0.6, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.7, size.width * 0.8, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
