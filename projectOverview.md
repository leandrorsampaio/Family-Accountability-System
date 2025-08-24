# Family Accountability System - Project Overview

## 📁 Flutter Project Structure

```
family_accountability_system/
├── lib/                          # 🎯 MAIN APP CODE (Dart files)
│   ├── main.dart                 # App entry point & initialization
│   ├── database/                 # 💾 Database layer
│   │   └── database_helper.dart  # SQLite operations & encryption
│   ├── models/                   # 📦 Data models (classes)
│   │   ├── expense.dart         
│   │   ├── composite_item.dart  
│   │   ├── category.dart        
│   │   └── user.dart            
│   ├── screens/                  # 📱 Full-screen pages
│   │   ├── login_screen.dart     # Password entry & database creation
│   │   └── main_screen.dart      # Main app layout with sidebar/tabs
│   ├── widgets/                  # 🧩 Reusable UI components
│   │   ├── month_sidebar.dart    # Left sidebar month navigation
│   │   ├── expense_tabs.dart     # Husband/Wife tabs
│   │   ├── expense_list.dart     # Expense display & management
│   │   └── expense_form.dart     # Add/edit expense dialog
│   └── theme/                    # 🎨 App styling
│       └── app_theme.dart        # Material Design blue theme
├── macos/                        # 🍎 macOS-specific configuration
├── pubspec.yaml                  # 📦 Dependencies & project config
└── build/                        # 🏗️ Compiled app output
```

## 🧠 App Logic Flow

### 1. **App Initialization** (`main.dart`)
```dart
void main() {
  sqfliteFfiInit();              // Initialize SQLite for desktop
  runApp(FamilyAccountabilityApp());
}
```

### 2. **Login Flow** (`login_screen.dart`)
- Checks if `database.db` exists
- Password entry → Database creation/access
- Encrypted database using AES-256

### 3. **Main App** (`main_screen.dart`)
- **Layout**: Sidebar + Main Content Area
- **Responsive**: Desktop (sidebar) vs Mobile (drawer)
- **State**: Current selected month

### 4. **Data Layer** (`database_helper.dart`)
```dart
// Singleton pattern for database access
DatabaseHelper().database  // Gets encrypted DB instance
```

### 5. **UI Components**
- **MonthSidebar**: Month selection (generates past/future months)
- **ExpenseTabs**: Husband/Wife tabs with TabController
- **ExpenseList**: CRUD operations for expenses
- **ExpenseForm**: Add/edit expense modal

## 🗄️ Database Schema

```sql
users           → id, name (Husband, Wife)
categories      → id, name (Food, Transport, Utilities)
subcategories   → id, category_id, name
expenses        → id, date, description, value, currency, user_id, flags
composite_items → id, expense_id, label, value (sub-items)
user_configs    → id, key, value (app settings)
```

## 🎨 Dart/Flutter Key Concepts

### **Widgets** (Everything is a widget)
```dart
// Stateless: UI doesn't change
class MyWidget extends StatelessWidget

// Stateful: UI can change (has setState())
class MyWidget extends StatefulWidget
```

### **State Management**
```dart
setState(() {
  _selectedMonth = newMonth;  // Triggers UI rebuild
});
```

### **Future/Async** (Database operations)
```dart
Future<void> _loadExpenses() async {
  final db = await DatabaseHelper().database;
  final expenses = await db.query('expenses');
}
```

### **Models** (Data classes)
```dart
class Expense {
  final int? id;
  final String description;
  // ... fromMap(), toMap() for database conversion
}
```

## 🔧 Key Files to Understand

1. **`main.dart`** - App setup & theme configuration
2. **`database_helper.dart`** - All database operations
3. **`main_screen.dart`** - Main app layout & navigation
4. **`expense_list.dart`** - Core CRUD functionality
5. **`app_theme.dart`** - Visual styling

## 🚀 Development Workflow

```bash
# Run in development mode
flutter run -d macos

# Build production app
flutter build macos --release

# Copy to desktop FAS folder
cp -r build/macos/Build/Products/Release/family_accountability_system.app /Users/leandrorossisampaio/Desktop/FAS/

# Hot reload (in running app)
# Press 'r' in terminal or save file
```

## 📦 Build Distribution
- **Location**: `/Users/leandrorossisampaio/Desktop/FAS/family_accountability_system.app`
- **Size**: ~44MB self-contained executable
- **Requirements**: macOS (no additional dependencies needed)

## 📊 Current Features

✅ **Completed Features:**
- Password-protected encrypted database (AES-256)
- Month-based expense organization
- Separate tracking for husband/wife
- Add/edit/delete expenses
- Tax deductible & shared expense flags
- Material Design blue theme
- Responsive design (desktop + mobile-ready)
- Test data: 3 categories with subcategories each

⏳ **Pending Features:**
- Complete expense form implementation with all fields
- Add composite items (inline sub-item editing)
- Enhanced multi-currency functionality
- Reporting features
- Import/export capabilities

## 🏗️ Architecture Notes

The app follows **MVC pattern**: 
- **Models** (data) → `lib/models/`
- **Views** (UI) → `lib/screens/` & `lib/widgets/`
- **Controller** (logic) → `database_helper.dart`

State flows down through widgets, events bubble up through callbacks. The app uses a singleton DatabaseHelper for centralized data access with proper encryption.

---
*Last updated: 2025-08-24*