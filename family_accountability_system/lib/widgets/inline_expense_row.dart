import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/expense.dart';
import '../database/database_helper.dart';

class InlineExpenseRow extends StatefulWidget {
  final Expense? expense;
  final int userId;
  final DateTime selectedMonth;
  final VoidCallback? onSaved;
  final VoidCallback? onDeleted;
  final bool isNewEntry;

  const InlineExpenseRow({
    super.key,
    this.expense,
    required this.userId,
    required this.selectedMonth,
    this.onSaved,
    this.onDeleted,
    this.isNewEntry = false,
  });

  @override
  State<InlineExpenseRow> createState() => _InlineExpenseRowState();
}

class _InlineExpenseRowState extends State<InlineExpenseRow> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _valueFocus = FocusNode();
  final FocusNode _taxFocus = FocusNode();
  final FocusNode _sharedFocus = FocusNode();
  
  bool _isEditing = false;
  bool _isSaving = false;
  String _currency = 'EUR';
  bool _isTaxDeductible = false;
  bool _isShared = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.expense != null) {
      final expense = widget.expense!;
      _descriptionController.text = expense.description;
      _valueController.text = expense.value.toString();
      _currency = expense.currency;
      _isTaxDeductible = expense.isTaxDeductible;
      _isShared = expense.isShared;
    } else if (widget.isNewEntry) {
      _isEditing = true;
      // Auto-focus on description for new entries
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _descriptionFocus.requestFocus();
      });
    }

    // Setup keyboard shortcuts
    _setupKeyboardListeners();
  }

  void _setupKeyboardListeners() {
    // No need for focus change listeners - we'll handle saving differently
  }

  void _clearFields() {
    setState(() {
      _descriptionController.clear();
      _valueController.clear();
      _isTaxDeductible = false;
      _isShared = false;
    });
    _descriptionFocus.requestFocus();
  }

  bool _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        _saveAndCreateNew();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        _clearFields();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        // Handle space for checkboxes
        if (_taxFocus.hasFocus) {
          setState(() {
            _isTaxDeductible = !_isTaxDeductible;
          });
          return true;
        } else if (_sharedFocus.hasFocus) {
          setState(() {
            _isShared = !_isShared;
          });
          return true;
        }
      }
    }
    return false;
  }

  double? _parseValue(String input) {
    if (input.trim().isEmpty) return null;
    
    // Handle + prefix for positive values
    String cleanInput = input.trim();
    bool isPositive = false;
    
    if (cleanInput.startsWith('+')) {
      isPositive = true;
      cleanInput = cleanInput.substring(1);
    }
    
    final value = double.tryParse(cleanInput);
    if (value == null) return null;
    
    // By default, make values negative (expenses), unless + prefix is used
    return isPositive ? value.abs() : -value.abs();
  }

  Future<void> _saveAndCreateNew() async {
    if (_isSaving) return;
    
    final description = _descriptionController.text.trim();
    final valueStr = _valueController.text.trim();
    
    if (description.isEmpty || valueStr.isEmpty) {
      // Incomplete, show error or focus on empty field
      if (description.isEmpty) {
        _descriptionFocus.requestFocus();
      } else {
        _valueFocus.requestFocus();
      }
      return;
    }
    
    final value = _parseValue(valueStr);
    if (value == null) {
      // Invalid value, focus on value field
      _valueFocus.requestFocus();
      return;
    }
    
    await _saveExpense(description, value);
    
    // After saving, clear fields and prepare for next entry (only for new entries)
    if (widget.isNewEntry) {
      _clearFields();
    }
  }

  Future<void> _saveExpense(String description, double value) async {
    if (_isSaving) return;
    
    setState(() {
      _isSaving = true;
    });

    try {
      final expense = Expense(
        id: widget.expense?.id,
        entryDate: DateTime.now(),
        selectedDate: widget.selectedMonth,
        description: description,
        value: value,
        currency: _currency,
        userId: widget.userId,
        isTaxDeductible: _isTaxDeductible,
        isShared: _isShared,
      );

      final db = await DatabaseHelper().database;
      
      if (widget.expense == null) {
        // Insert new expense
        await db.insert('expenses', expense.toMap());
      } else {
        // Update existing expense
        await db.update(
          'expenses',
          expense.toMap(),
          where: 'id = ?',
          whereArgs: [expense.id],
        );
      }

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
      
      widget.onSaved?.call();
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving expense: $e')),
        );
      }
    }
  }

  Future<void> _deleteExpense() async {
    if (widget.expense?.id == null) return;
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Delete "${widget.expense!.description}"?'),
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
        await db.delete('expenses', where: 'id = ?', whereArgs: [widget.expense!.id]);
        widget.onDeleted?.call();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting expense: $e')),
          );
        }
      }
    }
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
    _descriptionFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isNewEntry) {
      // Always show editing fields for new entries
      return KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: _handleKeyPress,
        child: _buildEditingRow(),
      );
    }
    
    if (_isEditing) {
      return KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: _handleKeyPress,
        child: _buildEditingRow(),
      );
    } else {
      return _buildDisplayRow();
    }
  }


  Widget _buildEditingRow() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Description field
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _descriptionController,
                    focusNode: _descriptionFocus,
                    decoration: const InputDecoration(
                      hintText: 'Description',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _valueFocus.requestFocus(),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Value field
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _valueController,
                    focusNode: _valueFocus,
                    decoration: const InputDecoration(
                      hintText: 'Amount (use + for income)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    onSubmitted: (_) => _saveAndCreateNew(),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Actions
                if (_isSaving)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: _saveAndCreateNew,
                        tooltip: 'Save (Enter)',
                      ),
                      if (widget.expense != null)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: _deleteExpense,
                          tooltip: 'Delete',
                        ),
                    ],
                  ),
              ],
            ),
            
            // Checkboxes row
            const SizedBox(height: 8),
            Row(
              children: [
                // Tax deductible checkbox
                Focus(
                  focusNode: _taxFocus,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isTaxDeductible = !_isTaxDeductible;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _isTaxDeductible,
                          onChanged: (value) {
                            setState(() {
                              _isTaxDeductible = value ?? false;
                            });
                          },
                        ),
                        const SizedBox(width: 4),
                        const Text('Tax Deductible'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                
                // Shared checkbox
                Focus(
                  focusNode: _sharedFocus,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isShared = !_isShared;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _isShared,
                          onChanged: (value) {
                            setState(() {
                              _isShared = value ?? false;
                            });
                          },
                        ),
                        const SizedBox(width: 4),
                        const Text('Shared'),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Keyboard shortcuts help
                Text(
                  'Enter: Save • Esc: Clear • Tab: Navigate • Space: Toggle',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayRow() {
    final expense = widget.expense!;
    
    return Card(
      child: InkWell(
        onTap: _startEditing,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Amount indicator
              CircleAvatar(
                backgroundColor: expense.value >= 0
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                child: Icon(
                  expense.value >= 0 ? Icons.add : Icons.remove,
                  color: expense.value >= 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              
              // Description and details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    if (expense.isTaxDeductible || expense.isShared)
                      const SizedBox(height: 4),
                    if (expense.isTaxDeductible || expense.isShared)
                      Wrap(
                        spacing: 4,
                        children: [
                          if (expense.isTaxDeductible)
                            Chip(
                              label: const Text('Tax'),
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
              ),
              
              // Amount
              Text(
                '${expense.value >= 0 ? '+' : ''}${expense.value.toStringAsFixed(2)} ${expense.currency}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: expense.value >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _valueController.dispose();
    _descriptionFocus.dispose();
    _valueFocus.dispose();
    _taxFocus.dispose();
    _sharedFocus.dispose();
    super.dispose();
  }
}