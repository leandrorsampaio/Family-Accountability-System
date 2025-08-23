import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const String _databaseName = 'database.db';
  static const int _databaseVersion = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get the directory for storing the database
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final String databasePath = path.join(appDocumentsDir.path, _databaseName);
    
    // Check if database file exists
    final bool exists = await File(databasePath).exists();
    
    if (!exists) {
      // Database doesn't exist, will be created with password
      throw DatabaseNotExistsException();
    }

    // Open existing database with password
    return await openDatabase(
      databasePath,
      version: _databaseVersion,
      password: _currentPassword,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  static String? _currentPassword;

  static void setPassword(String password) {
    _currentPassword = password;
  }

  Future<Database> createNewDatabase(String password) async {
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final String databasePath = path.join(appDocumentsDir.path, _databaseName);
    
    _currentPassword = password;
    
    return await openDatabase(
      databasePath,
      version: _databaseVersion,
      password: password,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // Create subcategories table
    await db.execute('''
      CREATE TABLE subcategories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Create expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entry_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        selected_date DATE NOT NULL,
        description TEXT NOT NULL,
        value REAL NOT NULL,
        currency TEXT DEFAULT 'EUR',
        category_id INTEGER,
        subcategory_id INTEGER,
        user_id INTEGER NOT NULL,
        is_tax_deductible BOOLEAN DEFAULT 0,
        is_shared BOOLEAN DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories (id),
        FOREIGN KEY (subcategory_id) REFERENCES subcategories (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Create composite_items table
    await db.execute('''
      CREATE TABLE composite_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expense_id INTEGER NOT NULL,
        label TEXT NOT NULL,
        value REAL NOT NULL,
        FOREIGN KEY (expense_id) REFERENCES expenses (id) ON DELETE CASCADE
      )
    ''');

    // Create user_configs table
    await db.execute('''
      CREATE TABLE user_configs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT NOT NULL UNIQUE,
        value TEXT NOT NULL
      )
    ''');

    // Seed initial data
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // Insert default users
    await db.insert('users', {'name': 'Husband'});
    await db.insert('users', {'name': 'Wife'});

    // Insert test categories and subcategories
    final foodId = await db.insert('categories', {'name': 'Food'});
    await db.insert('subcategories', {'category_id': foodId, 'name': 'Groceries'});
    await db.insert('subcategories', {'category_id': foodId, 'name': 'Restaurants'});
    await db.insert('subcategories', {'category_id': foodId, 'name': 'Snacks'});

    final transportId = await db.insert('categories', {'name': 'Transport'});
    await db.insert('subcategories', {'category_id': transportId, 'name': 'Fuel'});
    await db.insert('subcategories', {'category_id': transportId, 'name': 'Public Transport'});
    await db.insert('subcategories', {'category_id': transportId, 'name': 'Taxi'});

    final utilitiesId = await db.insert('categories', {'name': 'Utilities'});
    await db.insert('subcategories', {'category_id': utilitiesId, 'name': 'Electric'});
    await db.insert('subcategories', {'category_id': utilitiesId, 'name': 'Water'});
    await db.insert('subcategories', {'category_id': utilitiesId, 'name': 'Internet'});

    // Insert default config values
    await db.insert('user_configs', {'key': 'theme_mode', 'value': 'system'});
    await db.insert('user_configs', {'key': 'default_currency', 'value': 'EUR'});
    await db.insert('user_configs', {'key': 'primary_color', 'value': 'blue'});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

class DatabaseNotExistsException implements Exception {
  final String message = 'Database file does not exist';
  
  @override
  String toString() => 'DatabaseNotExistsException: $message';
}