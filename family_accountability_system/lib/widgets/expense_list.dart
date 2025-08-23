import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../database/database_helper.dart';
import '../widgets/expense_form.dart';

class ExpenseList extends StatefulWidget {
  final int userId;
  final DateTime selectedMonth;

  const ExpenseList({
    super.key,
    required this.userId,
    required this.selectedMonth,
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

  Future<void> _showExpenseForm([Expense? expense]) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
            maxHeight: 700,
          ),
          child: ExpenseForm(
            expense: expense,
            userId: widget.userId,
            selectedMonth: widget.selectedMonth,
          ),
        ),
      ),
    );

    if (result == true) {
      _loadExpenses();
    }
  }

  Future<void> _deleteExpense(Expense expense) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Are you sure you want to delete "${expense.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final db = await DatabaseHelper().database;
        await db.delete('expenses', where: 'id = ?', whereArgs: [expense.id]);
        _loadExpenses();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting expense: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.userId == 1 ? 'Husband' : 'Wife';
    
    return Column(
      children: [
        // Header with add button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
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
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showExpenseForm,
                icon: const Icon(Icons.add),
                label: const Text('Add Expense'),
              ),
            ],
          ),
        ),
        
        // Expense list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _expenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No expenses for ${DateFormat('MMMM yyyy').format(widget.selectedMonth)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap "Add Expense" to get started',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Scrollbar(
                      controller: _scrollController,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _expenses.length,
                        itemBuilder: (context, index) {
                          final expense = _expenses[index];
                          return _buildExpenseCard(expense);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: expense.value >= 0
              ? Colors.green.withOpacity(0.2)
              : Colors.red.withOpacity(0.2),
          child: Icon(
            expense.value >= 0 ? Icons.add : Icons.remove,
            color: expense.value >= 0 ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          expense.description,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('MMM dd, yyyy').format(expense.selectedDate)),
            if (expense.isTaxDeductible || expense.isShared)
              Row(
                children: [
                  if (expense.isTaxDeductible)
                    Chip(
                      label: const Text('Tax Deductible'),
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      labelStyle: const TextStyle(fontSize: 10),
                    ),
                  if (expense.isShared)
                    Chip(
                      label: const Text('Shared'),
                      backgroundColor: Colors.orange.withOpacity(0.1),
                      labelStyle: const TextStyle(fontSize: 10),
                    ),
                ],
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${expense.value >= 0 ? '+' : ''}${expense.value.toStringAsFixed(2)} ${expense.currency}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: expense.value >= 0 ? Colors.green : Colors.red,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showExpenseForm(expense);
                    break;
                  case 'delete':
                    _deleteExpense(expense);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}