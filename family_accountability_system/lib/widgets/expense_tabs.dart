import 'package:flutter/material.dart';
import '../widgets/expense_list.dart';

class ExpenseTabs extends StatefulWidget {
  final DateTime selectedMonth;

  const ExpenseTabs({
    super.key,
    required this.selectedMonth,
  });

  @override
  State<ExpenseTabs> createState() => _ExpenseTabsState();
}

class _ExpenseTabsState extends State<ExpenseTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.person),
                text: 'Husband',
              ),
              Tab(
                icon: Icon(Icons.person_outline),
                text: 'Wife',
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ExpenseList(
                userId: 1, // Husband ID
                selectedMonth: widget.selectedMonth,
              ),
              ExpenseList(
                userId: 2, // Wife ID
                selectedMonth: widget.selectedMonth,
              ),
            ],
          ),
        ),
      ],
    );
  }
}