import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../utils/app_logger.dart';

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
    AppLogger.database('INIT', 'Starting database initialization');
    
    // Get database path - try app directory first, fallback to Documents
    String databasePath;
    
    try {
      // Try to get the directory where the .app file is located (not inside it)
      final executablePath = Platform.resolvedExecutable;
      final appBundle = executablePath.replaceAll('/Contents/MacOS/family_accountability_system', '');
      final appDirectory = path.dirname(appBundle);
      databasePath = path.join(appDirectory, _databaseName);
      
      AppLogger.database('INIT', 'Executable path: $executablePath');
      AppLogger.database('INIT', 'App bundle: $appBundle');
      AppLogger.database('INIT', 'App directory: $appDirectory');
      AppLogger.database('INIT', 'Database path: $databasePath');
      
      // Test if we can write to the app directory
      final testPath = path.join(appDirectory, 'test_write.tmp');
      try {
        await File(testPath).writeAsString('test');
        await File(testPath).delete();
        AppLogger.database('INIT', 'App directory is writable');
      } catch (e) {
        AppLogger.warning('App directory not writable, falling back to Documents', e);
        final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
        databasePath = path.join(appDocumentsDir.path, _databaseName);
        AppLogger.database('INIT', 'Using Documents directory: ${appDocumentsDir.path}');
        AppLogger.database('INIT', 'Database path: $databasePath');
      }
    } catch (e) {
      AppLogger.error('Failed to determine app directory, using Documents', e);
      final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
      databasePath = path.join(appDocumentsDir.path, _databaseName);
      AppLogger.database('INIT', 'Using Documents directory fallback: ${appDocumentsDir.path}');
      AppLogger.database('INIT', 'Database path: $databasePath');
    }
    
    // Check if database file exists
    final bool exists = await File(databasePath).exists();
    AppLogger.database('INIT', 'Database exists: $exists');
    
    if (!exists) {
      // Database doesn't exist, will be created with password
      AppLogger.database('INIT', 'Database does not exist, throwing exception');
      throw DatabaseNotExistsException();
    }

    AppLogger.database('INIT', 'Opening existing database with password');
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
    AppLogger.database('CREATE', 'Starting new database creation');
    
    // Get database path - try app directory first, fallback to Documents
    String databasePath;
    
    try {
      // Try to get the directory where the .app file is located (not inside it)
      final executablePath = Platform.resolvedExecutable;
      final appBundle = executablePath.replaceAll('/Contents/MacOS/family_accountability_system', '');
      final appDirectory = path.dirname(appBundle);
      databasePath = path.join(appDirectory, _databaseName);
      
      AppLogger.database('CREATE', 'Executable path: $executablePath');
      AppLogger.database('CREATE', 'App bundle: $appBundle');
      AppLogger.database('CREATE', 'App directory: $appDirectory');
      AppLogger.database('CREATE', 'Database path: $databasePath');
      
      // Test if we can write to the app directory
      final testPath = path.join(appDirectory, 'test_write.tmp');
      try {
        await File(testPath).writeAsString('test');
        await File(testPath).delete();
        AppLogger.database('CREATE', 'App directory is writable - using FAS folder');
      } catch (e) {
        AppLogger.warning('App directory not writable, falling back to Documents', e);
        final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
        databasePath = path.join(appDocumentsDir.path, _databaseName);
        AppLogger.database('CREATE', 'Using Documents directory: ${appDocumentsDir.path}');
        AppLogger.database('CREATE', 'Database path: $databasePath');
      }
    } catch (e) {
      AppLogger.error('Failed to determine app directory, using Documents', e);
      final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
      databasePath = path.join(appDocumentsDir.path, _databaseName);
      AppLogger.database('CREATE', 'Using Documents directory fallback: ${appDocumentsDir.path}');
      AppLogger.database('CREATE', 'Database path: $databasePath');
    }
    
    _currentPassword = password;
    AppLogger.database('CREATE', 'Password set, creating database');
    
    try {
      final db = await openDatabase(
        databasePath,
        version: _databaseVersion,
        password: password,
        onCreate: _createTables,
        onUpgrade: _onUpgrade,
      );
      AppLogger.database('CREATE', 'Database created successfully');
      _database = db;
      return db;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create database', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _createTables(Database db, int version) async {
    AppLogger.database('CREATE_TABLES', 'Starting table creation');
    
    try {
      // Create users table
      AppLogger.database('CREATE_TABLES', 'Creating users table');
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
      AppLogger.database('CREATE_TABLES', 'All tables created, seeding initial data');
      await _seedInitialData(db);
      AppLogger.database('CREATE_TABLES', 'Table creation and seeding completed successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create tables', e, stackTrace);
      rethrow;
    }
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

  Future<List<DateTime>> getMonthsWithData() async {
    final db = await database;
    
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT DISTINCT 
        strftime('%Y', selected_date) as year,
        strftime('%m', selected_date) as month
      FROM expenses 
      ORDER BY year DESC, month DESC
    ''');
    
    return result.map((row) {
      final year = int.parse(row['year'] as String);
      final month = int.parse(row['month'] as String);
      return DateTime(year, month);
    }).toList();
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