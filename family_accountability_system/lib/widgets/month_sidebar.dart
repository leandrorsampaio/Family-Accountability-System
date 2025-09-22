import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class MonthSidebar extends StatefulWidget {
  final DateTime? selectedMonth;
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
  List<DateTime> _currentYearMonths = [];
  Map<int, List<DateTime>> _expenseMonthsByYear = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Generate all 12 months for current year
      final currentYear = DateTime.now().year;
      _currentYearMonths = List.generate(12, (index) => DateTime(currentYear, index + 1));
      
      // Load months that actually have expense data for reference
      final monthsWithData = await DatabaseHelper().getMonthsWithData();
      final Map<int, List<DateTime>> groupedByYear = {};
      
      for (final month in monthsWithData) {
        groupedByYear.putIfAbsent(month.year, () => []).add(month);
      }
      
      setState(() {
        _expenseMonthsByYear = groupedByYear;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _hasExpenseData(DateTime month) {
    final yearMonths = _expenseMonthsByYear[month.year];
    if (yearMonths == null) return false;
    return yearMonths.any((m) => m.year == month.year && m.month == month.month);
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
                : ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: _buildMonthList(),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMonthList() {
    final currentYear = DateTime.now().year;
    final List<Widget> monthWidgets = [];

    // Year header
    monthWidgets.add(
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '$currentYear',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Current Year',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Add all 12 months
    for (final month in _currentYearMonths) {
      monthWidgets.add(_buildMonthItem(month));
    }

    return monthWidgets;
  }

  Widget _buildMonthItem(DateTime month) {
    final isSelected = widget.selectedMonth != null &&
                      month.year == widget.selectedMonth!.year && 
                      month.month == widget.selectedMonth!.month;
    final isCurrentMonth = month.year == DateTime.now().year && 
                          month.month == DateTime.now().month;
    final hasData = _hasExpenseData(month);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => widget.onMonthSelected(month),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isCurrentMonth ? Icons.today : 
                  hasData ? Icons.calendar_month : Icons.calendar_month_outlined,
                  size: 20,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : hasData
                          ? Theme.of(context).colorScheme.onSurface.withOpacity(0.8)
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMMM').format(month),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : hasData
                                  ? null
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      if (isCurrentMonth)
                        Text(
                          'Current Month',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      else if (!hasData)
                        Text(
                          'No expenses yet',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                if (hasData)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.receipt,
                      size: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                if (isSelected)
                  const SizedBox(width: 8),
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

}