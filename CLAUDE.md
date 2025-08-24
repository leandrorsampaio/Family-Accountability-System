# Family Accountability System - Development Context

## Project Overview
A Flutter desktop application for managing family expenses with local SQLite database and encryption. The app operates completely offline and focuses on expense tracking with advanced categorization and reporting features.

## Technical Stack
- **Framework**: Flutter/Dart for desktop (macOS priority)
- **Database**: SQLite with sqflite_sqlcipher for AES-256 encryption
- **Storage**: Local database file (`database.db`) in executable directory
- **Security**: User-provided password for database encryption
- **Distribution**: Self-contained executable

## Key Features
1. **Expense Management**: Add, edit, delete expenses with detailed categorization
2. **Composite Items**: Break down complex purchases into sub-items
3. **User Management**: Multi-user support within family
4. **Advanced Filtering**: Date ranges, categories, tax-deductible status
5. **Reporting**: Generate reports based on various criteria
6. **Offline Operation**: No internet connectivity required

## Database Schema Summary
- `expenses`: Main expense records with categories, users, flags
- `composite_items`: Sub-items for detailed expense breakdowns  
- `categories`/`subcategories`: Hierarchical expense categorization
- `users`: Family members who can create expenses
- `user_configs`: App configuration and settings storage

## UI/UX Structure
- **Design**: Material Design with blueish color palette (configurable)
- **Layout**: Sidebar with month selection + main area with husband/wife tabs
- **Month Navigation**: All available months listed in left sidebar
- **User Tabs**: Husband and wife expense entries per selected month
- **Composite Items**: Checkbox to enable inline sub-item editing
- **Multi-Currency**: EUR default with support for additional currencies

## Initial Test Data
- 3 categories with 3 subcategories each for testing
- Sample: Food (Groceries, Restaurants, Snacks), Transport (Fuel, Public, Taxi), Utilities (Electric, Water, Internet)

## Security Requirements
- Database encryption at rest using AES-256
- Secure key management with flutter_secure_storage
- No data transmission (fully local)

## Development Commands
- `flutter run -d desktop`: Run app in desktop mode
- `flutter build windows/macos/linux`: Build for specific platform
- `flutter test`: Run unit tests
- `flutter analyze`: Static analysis

## Build & Distribution
- **Build Location**: `/Users/leandrorossisampaio/Desktop/FAS/`
- **Build Command**: `flutter build macos --release && cp -r build/macos/Build/Products/Release/family_accountability_system.app /Users/leandrorossisampaio/Desktop/FAS/`
- **App Size**: ~44MB (self-contained executable)

## Testing Strategy
- Unit tests for database operations
- Widget tests for UI components  
- Integration tests for complete workflows
- Platform-specific testing on Windows/macOS/Linux

## 📋 IMPORTANT REQUIREMENTS
- **Project Documentation**: Always keep `projectOverview.md` updated whenever project structure, features, or architecture changes
- **File Tracking**: Document any new files, moved files, or structural changes in the overview
- **Feature Status**: Maintain current status of completed vs pending features
- **Architecture Notes**: Update architecture explanations when patterns or approaches change