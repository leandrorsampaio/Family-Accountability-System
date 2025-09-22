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
  DateTime? _selectedMonth;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _sidebarRefreshKey = 0;

  void _onMonthSelected(DateTime month) {
    setState(() {
      _selectedMonth = month;
    });
    // Close drawer on mobile
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _refreshSidebar() {
    setState(() {
      _sidebarRefreshKey++;
    });
  }

  void _closeMonth() {
    setState(() {
      _selectedMonth = null;
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
        title: Text(_selectedMonth != null 
            ? 'Family Expenses - ${DateFormat('MMMM yyyy').format(_selectedMonth!)}'
            : 'Family Expenses'),
        leading: isDesktop 
          ? null 
          : IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
        actions: [
          if (_selectedMonth != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _closeMonth,
              tooltip: 'Close Month View',
            ),
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
          key: ValueKey('sidebar_mobile_$_sidebarRefreshKey'),
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
                key: ValueKey('sidebar_desktop_$_sidebarRefreshKey'),
                selectedMonth: _selectedMonth,
                onMonthSelected: _onMonthSelected,
              ),
            ),
            const VerticalDivider(width: 1),
          ],
          Expanded(
            child: _selectedMonth != null
                ? ExpenseTabs(
                    selectedMonth: _selectedMonth!,
                    onExpenseUpdated: _refreshSidebar,
                  )
                : _buildWelcomeScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    final currentYear = DateTime.now().year;
    
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 120,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 32),
            Text(
              'Family Accountability System',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome to your family expense tracking app',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select a Month to Get Started',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choose any month from $currentYear in the sidebar to start tracking your family expenses. You can track expenses for any month - whether it has data or not.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFeatureCard(
                  icon: Icons.people,
                  title: 'Multi-User',
                  description: 'Track expenses for\nboth partners',
                ),
                _buildFeatureCard(
                  icon: Icons.category,
                  title: 'Categories',
                  description: 'Organize expenses\nby categories',
                ),
                _buildFeatureCard(
                  icon: Icons.security,
                  title: 'Encrypted',
                  description: 'Your data is secure\nand private',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}