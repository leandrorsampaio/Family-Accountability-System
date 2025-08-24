import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/month_sidebar.dart';
import '../widgets/expense_tabs.dart';
import 'debug_logs_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onMonthSelected(DateTime month) {
    setState(() {
      _selectedMonth = month;
    });
    // Close drawer on mobile
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Family Expenses - ${DateFormat('MMMM yyyy').format(_selectedMonth)}'),
        leading: isDesktop 
          ? null 
          : IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const DebugLogsScreen()),
              );
            },
            tooltip: 'Debug Logs',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      drawer: isDesktop ? null : Drawer(
        child: MonthSidebar(
          selectedMonth: _selectedMonth,
          onMonthSelected: _onMonthSelected,
        ),
      ),
      body: Row(
        children: [
          if (isDesktop) ...[
            SizedBox(
              width: 280,
              child: MonthSidebar(
                selectedMonth: _selectedMonth,
                onMonthSelected: _onMonthSelected,
              ),
            ),
            const VerticalDivider(width: 1),
          ],
          Expanded(
            child: ExpenseTabs(selectedMonth: _selectedMonth),
          ),
        ],
      ),
    );
  }
}