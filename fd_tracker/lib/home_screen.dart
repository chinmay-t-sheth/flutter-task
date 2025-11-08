// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'fd_provider.dart';
import 'fd.dart';
import 'add_fd_screen.dart';
import 'fd_detail_screen.dart';
import 'dashboard_screen.dart';
import 'interest_log_screen.dart';
import 'settings_screen.dart';
import 'enums.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  FDSortOption _sortOption = FDSortOption.maturityDate;
  FilterStatus _filterStatus = FilterStatus.all;
  bool _isAscending = true;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _showStats = false;

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(amount);
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FDProvider>(context, listen: false).fetchFDsAndLogs().then((_) {
        _animationController.forward();
        setState(() => _showStats = true);

        // Check for upcoming maturities
        final provider = Provider.of<FDProvider>(context, listen: false);
        final upcomingMaturities = provider.fds.where((fd) {
          if (fd.status.toLowerCase() != 'active') return false;
          final daysLeft = _daysRemaining(fd);
          return daysLeft > 0 && daysLeft <= 7;
        }).toList();

        if (upcomingMaturities.isNotEmpty && mounted) {
          Future.delayed(const Duration(seconds: 1), () {
            _showAppMaturityAlert(context, upcomingMaturities);
          });
        }
      }).catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load data: $error'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showSortFilterSheet() {
    // Local state for modal
    FilterStatus localFilterStatus = _filterStatus;
    FDSortOption localSortOption = _sortOption;
    bool localIsAscending = _isAscending;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sort & Filter',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Filter Section
                    Text(
                      'FILTER BY STATUS',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: FilterStatus.values.map((status) {
                        final isSelected = localFilterStatus == status;
                        return ChoiceChip(
                          label: Text(_getFilterDisplayText(status)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setModalState(() {
                              localFilterStatus = status;
                            });
                          },
                          selectedColor: Theme.of(context).colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // Sort Section
                    Text(
                      'SORT BY',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: FDSortOption.values.map((option) {
                          final isSelected = localSortOption == option;
                          return RadioListTile<FDSortOption>(
                            title: Row(
                              children: [
                                Icon(_getSortOptionIcon(option), size: 20),
                                const SizedBox(width: 12),
                                Text(_getSortOptionText(option)),
                              ],
                            ),
                            value: option,
                            groupValue: localSortOption,
                            onChanged: (value) {
                              setModalState(() {
                                localSortOption = value!;
                              });
                            },
                            activeColor: Theme.of(context).colorScheme.primary,
                            dense: true,
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Order Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SwitchListTile(
                        title: Text('Sort Order'),
                        subtitle: Text(localIsAscending ? 'Ascending' : 'Descending'),
                        value: localIsAscending,
                        onChanged: (value) {
                          setModalState(() {
                            localIsAscending = value;
                          });
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Apply Button
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
                          print('✅ APPLIED: Filter: $_filterStatus, Sort: $_sortOption, Ascending: $_isAscending');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          'APPLY FILTERS',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ADD THESE HELPER METHODS:

  String _getFilterDisplayText(FilterStatus status) {
    switch (status) {
      case FilterStatus.all:
        return 'All';
      case FilterStatus.active:
        return 'Active';
      case FilterStatus.matured:
        return 'Matured';
    }
  }

  IconData _getSortOptionIcon(FDSortOption option) {
    switch (option) {
      case FDSortOption.maturityDate:
        return Icons.calendar_today_rounded;
      case FDSortOption.principal:
        return Icons.account_balance_wallet_rounded;
      case FDSortOption.interestRate:
        return Icons.trending_up_rounded;
      case FDSortOption.creationDate:
        return Icons.date_range_rounded;
      case FDSortOption.bankName:
        return Icons.account_balance_rounded;
    }
  }

  String _getSortOptionText(FDSortOption option) {
    switch (option) {
      case FDSortOption.maturityDate:
        return 'Maturity Date';
      case FDSortOption.principal:
        return 'Principal Amount';
      case FDSortOption.interestRate:
        return 'Interest Rate';
      case FDSortOption.creationDate:
        return 'Creation Date';
      case FDSortOption.bankName:
        return 'Bank Name';
    }
  }

  Future<bool?> _confirmDelete(FD fd) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Delete FD?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete "${fd.title}"? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _daysRemaining(FD fd) {
    final now = DateTime.now();
    final maturityDayStart = DateTime(fd.maturityDate.year, fd.maturityDate.month, fd.maturityDate.day);
    final todayStart = DateTime(now.year, now.month, now.day);
    if (maturityDayStart.isBefore(todayStart)) return 0;
    return maturityDayStart.difference(todayStart).inDays;
  }

  void _showAppMaturityAlert(BuildContext context, List<FD> upcomingFds) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Maturity Alert!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'The following FDs are maturing soon:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              ...upcomingFds.map((fd) {
                final daysLeft = _daysRemaining(fd);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(fd.title, style: theme.textTheme.bodyMedium)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: daysLeft <= 3 ? theme.colorScheme.error : theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$daysLeft days',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Got It'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankInvestmentSection(BuildContext context, FDProvider fdProvider) {
    // Calculate total investment per bank
    final Map<String, double> bankInvestments = {};
    for (var fd in fdProvider.fds) {
      if (fd.status.toLowerCase() == 'active') {
        bankInvestments[fd.bankName] = (bankInvestments[fd.bankName] ?? 0) + fd.principal;
      }
    }

    if (bankInvestments.isEmpty) return const SizedBox.shrink();

    // Convert to list and sort by investment amount (descending)
    final bankList = bankInvestments.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Investment by Bank',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...bankList.map((bank) {
            final percentage = (bank.value / bankInvestments.values.reduce((a, b) => a + b)) * 100;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          bank.key,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatCurrency(bank.value),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Active Investment',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatCurrency(bankInvestments.values.reduce((a, b) => a + b)),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('My Fixed Deposits'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, size: 24),
            onPressed: () {
              showSearch(
                context: context,
                delegate: HomeSearchDelegate(
                  Provider.of<FDProvider>(context, listen: false).getFilteredAndSortedFDs(
                    filter: _filterStatus,
                    sortBy: _sortOption,
                    ascending: _isAscending,
                  ),
                  _formatCurrency,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_alt_rounded, size: 24),
            onPressed: _showSortFilterSheet,
          ),
          IconButton(
            icon: Icon(Icons.dashboard_rounded, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<FDProvider>(
        builder: (context, fdProvider, child) {
          final filteredFds = fdProvider.getFilteredAndSortedFDs(
            filter: _filterStatus,
            sortBy: _sortOption,
            ascending: _isAscending,
          );

          print('🏠 HOME SCREEN: Displaying ${filteredFds.length} FDs');
          print('🏠 HOME SCREEN: Filter: $_filterStatus, Sort: $_sortOption, Ascending: $_isAscending');

          if (fdProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Stats Cards
                  SliverToBoxAdapter(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _showStats ? _buildStatsSection(context, fdProvider) : const SizedBox.shrink(),
                    ),
                  ),

                  // Bank Investment Section
                  SliverToBoxAdapter(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _showStats ? _buildBankInvestmentSection(context, fdProvider) : const SizedBox.shrink(),
                    ),
                  ),

                  // Filter & Sort Info Chip
                  SliverToBoxAdapter(
                    child: _buildFilterSortInfo(context),
                  ),

                  // Add FD Button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_rounded, size: 22),
                        label: const Text('Add New FD', style: TextStyle(fontWeight: FontWeight.w600)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddFDScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ),

                  // FD List
                  if (filteredFds.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyState(context),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      sliver: AnimationLimiter(
                        child: SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              final fd = filteredFds[index];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 500),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: _buildFDItem(context, fd, fdProvider),
                                  ),
                                ),
                              );
                            },
                            childCount: filteredFds.length,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        scale: _showStats ? 1.0 : 0.0,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddFDScreen()),
            );
          },
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }

  Widget _buildFilterSortInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          if (_filterStatus != FilterStatus.all)
            Chip(
              label: Text(
                'Filter: ${_getFilterDisplayText(_filterStatus)}',
                style: TextStyle(fontSize: 12),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          if (_sortOption != FDSortOption.maturityDate)
            Chip(
              label: Text(
                'Sort: ${_getSortDisplayText(_sortOption)}',
                style: TextStyle(fontSize: 12),
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ),
          if (!_isAscending)
            Chip(
              label: Text(
                'Descending',
                style: TextStyle(fontSize: 12),
              ),
              backgroundColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
            ),
        ],
      ),
    );
  }

  String _getSortDisplayText(FDSortOption option) {
    switch (option) {
      case FDSortOption.maturityDate:
        return 'Maturity Date';
      case FDSortOption.principal:
        return 'Principal';
      case FDSortOption.interestRate:
        return 'Interest Rate';
      case FDSortOption.creationDate:
        return 'Creation Date';
      case FDSortOption.bankName:
        return 'Bank Name';
    }
  }

  Widget _buildStatsSection(BuildContext context, FDProvider fdProvider) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            Icons.account_balance_wallet_rounded,
            'Total Invested',
            _formatCurrency(fdProvider.totalPrincipal),
          ),
          _buildStatItem(
            context,
            Icons.trending_up_rounded,
            'Active FDs',
            '${fdProvider.fds.where((fd) => fd.status.toLowerCase() == 'active').length}',
          ),
          _buildStatItem(
            context,
            Icons.savings_rounded,
            'Upcoming Interest',
            _formatCurrency(fdProvider.totalUpcomingInterest),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String title, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.account_balance_wallet_outlined,
          size: 80,
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
        const SizedBox(height: 20),
        Text(
          'No FDs Found',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _filterStatus == FilterStatus.all
              ? 'Start by adding your first fixed deposit'
              : 'No FDs match the current filter',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add FD'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddFDScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildFDItem(BuildContext context, FD fd, FDProvider fdProvider) {
    final statusColor = _getStatusColor(fd.status);
    final daysRemaining = _daysRemaining(fd);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surface,
        elevation: 2,
        shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FDDetailScreen(fd: fd)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStatusIcon(fd.status),
                        color: statusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fd.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            fd.bankName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatCurrency(fd.principal),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${fd.rate}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Details Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 8,
                  children: [
                    _buildDetailChip(
                      context,
                      Icons.calendar_today_rounded,
                      'Maturity',
                      DateFormat('dd MMM yyyy').format(fd.maturityDate),
                    ),
                    _buildDetailChip(
                      context,
                      Icons.trending_up_rounded,
                      'Maturity Value',
                      _formatCurrency(fd.maturityAmount ?? 0),
                    ),
                    if (daysRemaining > 0 && fd.status.toLowerCase() == 'active')
                      _buildDetailChip(
                        context,
                        Icons.schedule_rounded,
                        'Days Left',
                        '$daysRemaining days',
                        color: daysRemaining <= 7 ? Theme.of(context).colorScheme.error : null,
                      ),
                    _buildDetailChip(
                      context,
                      Icons.info_rounded,
                      'Status',
                      fd.status.capitalize,
                      color: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(
                      context,
                      Icons.receipt_long_rounded,
                      'Logs',
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => InterestLogScreen(fd: fd))),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      context,
                      Icons.edit_rounded,
                      'Edit',
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddFDScreen(fdToEdit: fd))),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      context,
                      Icons.delete_outline_rounded,
                      'Delete',
                          () async {
                        final shouldDelete = await _confirmDelete(fd);
                        if (shouldDelete == true && fd.id != null) {
                          await fdProvider.deleteFD(fd.id!);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${fd.title} deleted successfully'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        }
                      },
                      isDestructive: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(BuildContext context, IconData icon, String title, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color ?? Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary;

    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Theme.of(context).colorScheme.primary;
      case 'matured':
        return Theme.of(context).colorScheme.secondary;
      case 'closed':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.play_arrow_rounded;
      case 'matured':
        return Icons.check_circle_rounded;
      case 'closed':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}

class HomeSearchDelegate extends SearchDelegate {
  final List<FD> fds;
  final String Function(double) formatCurrency;

  HomeSearchDelegate(this.fds, this.formatCurrency);

  List<FD> _filterFDs(List<FD> fds, String query) {
    if (query.isEmpty) return fds;
    return fds.where((fd) =>
    fd.title.toLowerCase().contains(query.toLowerCase()) ||
        fd.bankName.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: query.isNotEmpty ? 1.0 : 0.0,
        child: IconButton(
          icon: const Icon(Icons.clear_rounded),
          onPressed: () {
            query = '';
          },
        ),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _filterFDs(fds, query);
    return _buildSearchResults(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = _filterFDs(fds, query);
    return _buildSearchResults(context, results);
  }

  Widget _buildSearchResults(BuildContext context, List<FD> results) {
    final theme = Theme.of(context);

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No FDs found matching "$query"',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final fd = results[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Material(
                    borderRadius: BorderRadius.circular(16),
                    color: theme.colorScheme.surface,
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(fd.title, style: theme.textTheme.titleMedium),
                      subtitle: Text(fd.bankName, style: theme.textTheme.bodyMedium),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatCurrency(fd.principal),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${fd.rate}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FDDetailScreen(fd: fd),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

extension StringExtension on String {
  String get capitalize => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}