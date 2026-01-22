# Hoogli Bakery POS (Flutter)

A Flutter-based POS (Point of Sale) application for **Hoogli Bakery**, designed for bakery + restaurant billing.  
Includes product management, quick sales screen, checkout, invoice generation, receipt printing (58mm), and sales reports.

---

## Features

### ✅ Product Management
- Category CRUD
- Product CRUD
- Variants support (Half Pound, 1 Pound, Slice, etc.)
- Add-ons support (Candle, Knife, Toppings, etc.)

### ✅ POS Sales Flow
- New Sale screen with:
  - Category buttons
  - Product grid
  - Search products
  - Add to cart
- Checkout:
  - Subtotal
  - Discount (Flat / Percent)
  - Total calculation
  - Payment methods (Cash, bKash, Nagad, Card)
  - Paid amount + Due calculation

### ✅ Invoice & Receipt
- Auto invoice number format: `HB-000001` (auto increment)
- 58mm thermal receipt printing
- Printable receipt string generator

### ✅ Reports
- Today total sales
- Payment breakdown
- Total orders

### ✅ Roles
- Admin
- Cashier

---

## Tech Stack
- **Flutter**
- **Dart**
- Local DB: (SQLite / Hive / Isar / Firebase) *(update based on your implementation)*

---

## Screens (Planned / Implemented)
- Login
- Dashboard
- Products (Category, Product, Variant)
- Add-ons Management
- New Sale Screen
- Checkout Screen
- Reports Screen
- Receipt Print Preview

---

