class Expense {
  final int? id;
  final DateTime entryDate;
  final DateTime selectedDate;
  final String description;
  final double value;
  final String currency;
  final int? categoryId;
  final int? subcategoryId;
  final int userId;
  final bool isTaxDeductible;
  final bool isShared;

  Expense({
    this.id,
    required this.entryDate,
    required this.selectedDate,
    required this.description,
    required this.value,
    this.currency = 'EUR',
    this.categoryId,
    this.subcategoryId,
    required this.userId,
    this.isTaxDeductible = false,
    this.isShared = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entry_date': entryDate.toIso8601String(),
      'selected_date': selectedDate.toIso8601String(),
      'description': description,
      'value': value,
      'currency': currency,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'user_id': userId,
      'is_tax_deductible': isTaxDeductible ? 1 : 0,
      'is_shared': isShared ? 1 : 0,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      entryDate: DateTime.parse(map['entry_date']),
      selectedDate: DateTime.parse(map['selected_date']),
      description: map['description'],
      value: map['value'].toDouble(),
      currency: map['currency'] ?? 'EUR',
      categoryId: map['category_id'],
      subcategoryId: map['subcategory_id'],
      userId: map['user_id'],
      isTaxDeductible: map['is_tax_deductible'] == 1,
      isShared: map['is_shared'] == 1,
    );
  }

  Expense copyWith({
    int? id,
    DateTime? entryDate,
    DateTime? selectedDate,
    String? description,
    double? value,
    String? currency,
    int? categoryId,
    int? subcategoryId,
    int? userId,
    bool? isTaxDeductible,
    bool? isShared,
  }) {
    return Expense(
      id: id ?? this.id,
      entryDate: entryDate ?? this.entryDate,
      selectedDate: selectedDate ?? this.selectedDate,
      description: description ?? this.description,
      value: value ?? this.value,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      userId: userId ?? this.userId,
      isTaxDeductible: isTaxDeductible ?? this.isTaxDeductible,
      isShared: isShared ?? this.isShared,
    );
  }
}