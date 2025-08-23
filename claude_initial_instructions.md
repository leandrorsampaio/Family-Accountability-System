# Family Accountability System – Development Instructions  
*Note: This is a placeholder project name and may change in the future.*

## 1. General Requirements

- The app must be built using **Flutter** and **Dart**.
- It should run **locally on a desktop** (Windows/macOS/Linux) without requiring any internet access.
- Upon launch, the app must:
  - Check for a **database file named `database.db`** in the **same directory** as the executable.
  - If the file does not exist, display a message:  
    **“The database file 'database.db' was not found. Do you want to create a new one?”**  
    Only create the database if the user confirms with “Yes”.

- All database content must be **encrypted at rest**, using the `sqflite_sqlcipher` package.

---

## 2. Database Encryption

The app uses [`sqflite_sqlcipher`](https://pub.dev/packages/sqflite_sqlcipher), which is a drop-in replacement for `sqflite` and enables **AES-256 encryption** for SQLite databases.

### Why use `sqflite_sqlcipher`?

| Feature                        | Value                                       |
|-------------------------------|---------------------------------------------|
| Encryption method             | AES-256                                     |
| Platform support              | Android, iOS, macOS, Windows, Linux         |
| Integration                   | Compatible with `sqflite_common`            |
| Key storage                   | You may use `flutter_secure_storage` or a user-provided passphrase |

---

## 3. Database Schema

### `expenses` table

| Field Name         | Type       | Description                                           |
|--------------------|------------|-------------------------------------------------------|
| `id`               | INTEGER PK | Unique identifier                                     |
| `entry_date`       | DATETIME   | Automatically set when the record is created          |
| `selected_date`    | DATE       | User-defined date of the expense                      |
| `description`      | TEXT       | Description of the expense                            |
| `value`            | REAL       | Positive or negative value                            |
| `currency`         | TEXT       | Currency code, default to `EUR`                       |
| `category_id`      | INTEGER FK | Linked to `categories.id`                             |
| `subcategory_id`   | INTEGER FK | Linked to `subcategories.id`                          |
| `user_id`          | INTEGER FK | Linked to `users.id`                                  |
| `is_tax_deductible`| BOOLEAN    | True/False checkbox for tax-deductible expenses       |
| `is_shared`        | BOOLEAN    | True/False checkbox if expense is shared              |

### `composite_items` table (optional sub-values for composite expenses)

| Field Name   | Type       | Description                          |
|--------------|------------|--------------------------------------|
| `id`         | INTEGER PK | Unique identifier                    |
| `expense_id` | INTEGER FK | Linked to `expenses.id`              |
| `label`      | TEXT       | Description of the individual item   |
| `value`      | REAL       | Value of this sub-item               |

### `categories` table

| Field Name | Type       | Description        |
|------------|------------|--------------------|
| `id`       | INTEGER PK | Unique category ID |
| `name`     | TEXT       | Main category name |

### `subcategories` table

| Field Name    | Type       | Description               |
|---------------|------------|---------------------------|
| `id`          | INTEGER PK | Unique subcategory ID     |
| `category_id` | INTEGER FK | Linked to `categories.id` |
| `name`        | TEXT       | Subcategory name          |

### `users` table

| Field Name | Type       | Description      |
|------------|------------|------------------|
| `id`       | INTEGER PK | Unique user ID   |
| `name`     | TEXT       | Name of the user |

---

## 4. Functionality Notes

- **Encryption**: Use `sqflite_sqlcipher` to transparently encrypt all data using AES-256.
- **Composite Expenses**: Users should be able to add detailed sub-values for composite purchases (e.g., Amazon orders).
- **Check boxes**: Use `is_shared` and `is_tax_deductible` flags for advanced reporting.
- **Filtering/Reporting**: Allow filtering by:
  - Date range
  - Category/subcategory
  - Tax-deductible or shared status
  - Composite breakdowns