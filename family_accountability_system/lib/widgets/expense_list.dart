import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../database/database_helper.dart';
import '../widgets/inline_expense_row.dart';

class ExpenseList extends StatefulWidget {
  final int userId;
  final DateTime selectedMonth;
  final VoidCallback? onExpenseUpdated;

  const ExpenseList({
    super.key,
    required this.userId,
    required this.selectedMonth,
    this.onExpenseUpdated,
  });

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  List<Expense> _expenses = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  @override
  void didUpdateWidget(ExpenseList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMonth != widget.selectedMonth ||
        oldWidget.userId != widget.userId) {
      _loadExpenses();
    }
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final db = await DatabaseHelper().database;
      final startDate = DateTime(widget.selectedMonth.year, widget.selectedMonth.month, 1);
      final endDate = DateTime(widget.selectedMonth.year, widget.selectedMonth.month + 1, 1);

      final List<Map<String, dynamic>> maps = await db.query(
        'expenses',
        where: 'user_id = ? AND selected_date >= ? AND selected_date < ?',
        whereArgs: [
          widget.userId,
          startDate.toIso8601String(),
          endDate.toIso8601String(),
        ],
        orderBy: 'selected_date DESC, entry_date DESC',
      );

      final expenses = maps.map((map) => Expense.fromMap(map)).toList();

      if (mounted) {
        setState(() {
          _expenses = expenses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading expenses: $e')),
        );
      }
    }
  }

  void _onExpenseChanged() {
    _loadExpenses();
    widget.onExpenseUpdated?.call();
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.userId == 1 ? 'Husband' : 'Wife';
    
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                '$userName\'s Expenses',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Values are expenses by default. Use + for income.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        
        // Expense list with inline editing
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildExpensesList(),
        ),
      ],
    );
  }

  Widget _buildExpensesList() {
    return Scrollbar(
      controller: _scrollController,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          // New entry row (always at top)
          InlineExpenseRow(
            userId: widget.userId,
            selectedMonth: widget.selectedMonth,
            onSaved: _onExpenseChanged,
            isNewEntry: true,
          ),
          
          // Existing expenses
          ..._expenses.map((expense) => InlineExpenseRow(
            expense: expense,
            userId: widget.userId,
            selectedMonth: widget.selectedMonth,
            onSaved: _onExpenseChanged,
            onDeleted: _onExpenseChanged,
          )),
          
          // Empty state message if no expenses
          if (_expenses.isEmpty)
            Container(
              margin: const EdgeInsets.only(top: 32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No expenses yet for ${DateFormat('MMMM yyyy').format(widget.selectedMonth)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start adding expenses using the row above',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}