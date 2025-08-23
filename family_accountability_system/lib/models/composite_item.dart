class CompositeItem {
  final int? id;
  final int expenseId;
  final String label;
  final double value;

  CompositeItem({
    this.id,
    required this.expenseId,
    required this.label,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expense_id': expenseId,
      'label': label,
      'value': value,
    };
  }

  factory CompositeItem.fromMap(Map<String, dynamic> map) {
    return CompositeItem(
      id: map['id'],
      expenseId: map['expense_id'],
      label: map['label'],
      value: map['value'].toDouble(),
    );
  }

  CompositeItem copyWith({
    int? id,
    int? expenseId,
    String? label,
    double? value,
  }) {
    return CompositeItem(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      label: label ?? this.label,
      value: value ?? this.value,
    );
  }
}