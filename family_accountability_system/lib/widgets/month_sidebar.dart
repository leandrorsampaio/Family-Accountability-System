import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthSidebar extends StatelessWidget {
  final DateTime selectedMonth;
  final Function(DateTime) onMonthSelected;

  const MonthSidebar({
    super.key,
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  List<DateTime> _generateMonths() {
    final List<DateTime> months = [];
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    // Add 12 months back from current month
    for (int i = 11; i >= 0; i--) {
      final month = DateTime(currentYear, currentMonth - i);
      months.add(month);
    }

    // Add next 12 months
    for (int i = 1; i <= 12; i++) {
      final month = DateTime(currentYear, currentMonth + i);
      months.add(month);
    }

    return months;
  }

  @override
  Widget build(BuildContext context) {
    final months = _generateMonths();
    
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
            child: ListView.builder(
              itemCount: months.length,
              itemBuilder: (context, index) {
                final month = months[index];
                final isSelected = month.year == selectedMonth.year && 
                                 month.month == selectedMonth.month;
                final isCurrentMonth = month.year == DateTime.now().year && 
                                     month.month == DateTime.now().month;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Material(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => onMonthSelected(month),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 12
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isCurrentMonth 
                                  ? Icons.today
                                  : Icons.calendar_month,
                              size: 20,
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
                                    DateFormat('MMMM yyyy').format(month),
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
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}