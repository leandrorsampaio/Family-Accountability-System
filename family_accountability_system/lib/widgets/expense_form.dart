import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseForm extends StatefulWidget {
  final Expense? expense;
  final int userId;
  final DateTime selectedMonth;

  const ExpenseForm({
    super.key,
    this.expense,
    required this.userId,
    required this.selectedMonth,
  });

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  
  DateTime? _selectedDate;
  String _currency = 'EUR';
  bool _isTaxDeductible = false;
  bool _isShared = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedMonth;
    
    if (widget.expense != null) {
      final expense = widget.expense!;
      _descriptionController.text = expense.description;
      _valueController.text = expense.value.toString();
      _selectedDate = expense.selectedDate;
      _currency = expense.currency;
      _isTaxDeductible = expense.isTaxDeductible;
      _isShared = expense.isShared;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
        actions: [
          TextButton(
            onPressed: _saveExpense,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Tax Deductible'),
                value: _isTaxDeductible,
                onChanged: (value) {
                  setState(() {
                    _isTaxDeductible = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Shared Expense'),
                value: _isShared,
                onChanged: (value) {
                  setState(() {
                    _isShared = value ?? false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveExpense() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement expense saving
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }
}