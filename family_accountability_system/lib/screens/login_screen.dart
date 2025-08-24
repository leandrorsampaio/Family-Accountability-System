import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../database/database_helper.dart';
import '../utils/app_logger.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _databaseExists = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkDatabaseExists();
  }

  Future<void> _checkDatabaseExists() async {
    AppLogger.auth('Checking if database exists');
    
    try {
      // Check in executable directory first
      String databasePath;
      
      try {
        final executablePath = Platform.resolvedExecutable;
        final executableDir = path.dirname(executablePath);
        databasePath = path.join(executableDir, 'database.db');
        AppLogger.auth('Checking database path: $databasePath');
      } catch (e) {
        // Fallback to Documents directory
        AppLogger.warning('Failed to get executable directory, checking Documents', e);
        final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
        databasePath = path.join(appDocumentsDir.path, 'database.db');
        AppLogger.auth('Checking fallback database path: $databasePath');
      }
      
      final bool exists = await File(databasePath).exists();
      AppLogger.auth('Database exists: $exists at $databasePath');
      
      setState(() {
        _databaseExists = exists;
      });
    } catch (e, stackTrace) {
      AppLogger.error('Error checking database existence', e, stackTrace);
      setState(() {
        _databaseExists = false;
      });
    }
  }

  Future<void> _handleLogin() async {
    AppLogger.auth('Login attempt started');
    
    if (_passwordController.text.isEmpty) {
      AppLogger.auth('Login failed: empty password');
      _showError('Please enter a password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dbHelper = DatabaseHelper();
      DatabaseHelper.setPassword(_passwordController.text);
      AppLogger.auth('Password set, database exists: $_databaseExists');
      
      if (_databaseExists) {
        // Try to open existing database
        AppLogger.auth('Attempting to open existing database');
        await dbHelper.database;
        AppLogger.auth('Successfully opened existing database');
      } else {
        // Create new database
        AppLogger.auth('Attempting to create new database');
        await dbHelper.createNewDatabase(_passwordController.text);
        AppLogger.auth('Successfully created new database');
      }

      // Navigate to main screen
      AppLogger.auth('Login successful, navigating to main screen');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Login failed', e, stackTrace);
      _showError(_databaseExists 
        ? 'Invalid password. Please try again.' 
        : 'Failed to create database. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showCreateDatabaseDialog() async {
    final bool? shouldCreate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Database Not Found'),
        content: const Text('The database file \'database.db\' was not found. Do you want to create a new one?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Create'),
          ),
        ],
      ),
    );

    if (shouldCreate == true) {
      setState(() {
        _databaseExists = false;
      });
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            elevation: 8,
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Family Accountability System',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (!_databaseExists) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text('Creating new encrypted database'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: _databaseExists ? 'Database Password' : 'Set Database Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    onSubmitted: (_) => _handleLogin(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_databaseExists ? 'Login' : 'Create Database'),
                  ),
                  if (_databaseExists) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _showCreateDatabaseDialog,
                      child: const Text('Create New Database Instead'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}