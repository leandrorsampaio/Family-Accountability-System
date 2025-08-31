import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class MonthSidebar extends StatefulWidget {
  final DateTime selectedMonth;
  final Function(DateTime) onMonthSelected;

  const MonthSidebar({
    super.key,
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  @override
  State<MonthSidebar> createState() => _MonthSidebarState();
}

class _MonthSidebarState extends State<MonthSidebar> {
  Map<int, List<DateTime>> _monthsByYear = {};
  Set<int> _expandedYears = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonthsWithData();
  }

  Future<void> _loadMonthsWithData() async {
    try {
      final monthsWithData = await DatabaseHelper().getMonthsWithData();
      final Map<int, List<DateTime>> groupedByYear = {};
      
      for (final month in monthsWithData) {
        groupedByYear.putIfAbsent(month.year, () => []).add(month);
      }
      
      // Sort months within each year by month descending
      groupedByYear.forEach((year, months) {
        months.sort((a, b) => b.month.compareTo(a.month));
      });
      
      setState(() {
        _monthsByYear = groupedByYear;
        _isLoading = false;
        
        // Auto-expand the most recent year (current year or most recent year with data)
        if (_monthsByYear.isNotEmpty) {
          final currentYear = DateTime.now().year;
          if (_monthsByYear.containsKey(currentYear)) {
            _expandedYears.add(currentYear);
          } else {
            // Expand the most recent year with data
            final mostRecentYear = _monthsByYear.keys.reduce((a, b) => a > b ? a : b);
            _expandedYears.add(mostRecentYear);
          }
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleYear(int year) {
    setState(() {
      if (_expandedYears.contains(year)) {
        _expandedYears.remove(year);
      } else {
        _expandedYears.add(year);
      }
    });
  }

  void _addNewMonth(int year) {
    // Find the next available month in this year
    final existingMonths = _monthsByYear[year] ?? [];
    DateTime? newMonth;
    
    if (existingMonths.isEmpty) {
      // No months exist for this year, default to current month if it's current year, otherwise January
      if (year == DateTime.now().year) {
        newMonth = DateTime(year, DateTime.now().month);
      } else {
        newMonth = DateTime(year, 1);
      }
    } else {
      // Find a month that doesn't exist yet, starting from January
      int monthToAdd = 1;
      while (monthToAdd <= 12) {
        if (!existingMonths.any((m) => m.month == monthToAdd)) {
          newMonth = DateTime(year, monthToAdd);
          break;
        }
        monthToAdd++;
      }
      
      // If all months exist, don't do anything
      if (monthToAdd > 12) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All months already have data for this year')),
        );
        return;
      }
    }
    
    if (newMonth != null) {
      widget.onMonthSelected(newMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Select Month',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _monthsByYear.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No expense data found',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start adding expenses to see months here',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => widget.onMonthSelected(DateTime.now()),
                              icon: const Icon(Icons.add),
                              label: const Text('Start This Month'),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: _buildYearSections(),
                      ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildYearSections() {
    final sortedYears = _monthsByYear.keys.toList()..sort((a, b) => b.compareTo(a));
    final List<Widget> sections = [];

    for (final year in sortedYears) {
      final isExpanded = _expandedYears.contains(year);
      final months = _monthsByYear[year]!;
      final isCurrentYear = year == DateTime.now().year;

      // Year header
      sections.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _toggleYear(year),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$year',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (isCurrentYear) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Current',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      '${months.length} month${months.length != 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _addNewMonth(year),
                      icon: const Icon(Icons.add, size: 18),
                      tooltip: 'Add new month',
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Months list (if expanded)
      if (isExpanded) {
        for (final month in months) {
          sections.add(_buildMonthItem(month));
        }
      }
    }

    // Add current year if it doesn't exist in the data
    final currentYear = DateTime.now().year;
    if (!_monthsByYear.containsKey(currentYear)) {
      sections.add(_buildEmptyYearSection(currentYear));
    }

    return sections;
  }

  Widget _buildMonthItem(DateTime month) {
    final isSelected = month.year == widget.selectedMonth.year && 
                      month.month == widget.selectedMonth.month;
    final isCurrentMonth = month.year == DateTime.now().year && 
                          month.month == DateTime.now().month;

    return Container(
      margin: const EdgeInsets.only(left: 24, right: 8, top: 2, bottom: 2),
      child: Material(
        color: isSelected 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => widget.onMonthSelected(month),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(
                  isCurrentMonth ? Icons.today : Icons.calendar_month,
                  size: 18,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMMM').format(month),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                      if (isCurrentMonth)
                        Text(
                          'Current Month',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyYearSection(int year) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
              const SizedBox(width: 8),
              Text(
                '$year',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Current',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 10,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'No data',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _addNewMonth(year),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Month'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(0, 32),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}