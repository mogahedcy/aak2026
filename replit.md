# نظام إدارة Ahmed Abdulqader Company

## Overview
This project is an integrated management system developed in PHP with a PostgreSQL database, designed to manage core business operations for Ahmed Abdulqader Company. Its primary purpose is to streamline financial and inventory processes, supporting both Yemeni Rial and US Dollar currencies. The system aims to enhance efficiency in managing customers, suppliers, inventory, sales, purchases, financial vouchers, and electronic documents, providing a comprehensive solution for business administration.

## User Preferences
The system should prioritize ease of use and professional design. It should maintain a clear and intuitive user interface, especially for financial reports like account statements, which require a professional, print-ready format. Data integrity and security are paramount, particularly concerning financial transactions and inventory management. The system must support Arabic language fully with RTL (Right-to-Left) design. Any new features or modifications should integrate seamlessly with the existing dual-currency support and robust security measures.

## System Architecture
The system is built on PHP 8.2 with a PostgreSQL database. The frontend utilizes HTML5, CSS3, and JavaScript, with a strong emphasis on RTL design for full Arabic language support.

**Key Features:**

*   **Customer & Supplier Management:** Comprehensive management including detailed account statements and balance tracking in both YER and USD.
*   **Inventory & Product Management:** Supports multiple warehouses, real-time inventory tracking, and dual-currency pricing for purchase and sale. Includes features for managing product expiry dates with alerts, initial stock entry, quick stock additions, and inventory source tracking (purchases, opening stock, returns).
*   **Invoicing System:** Manages sales and purchase invoices, with automatic calculation of totals and discounts, payment status tracking, and professional print-ready templates.
    *   **Purchases Module (v9.0 - October 2025):**
        *   Complete purchase invoice management with detailed view page
        *   **Expiry Date Tracking:** Product expiry dates can now be entered per item during purchase invoice creation and are stored in inventory for tracking
        *   Purchase returns system with robust validation
        *   Per-product quantity tracking for returns (prevents over-returning)
        *   Automatic supplier balance adjustments
        *   Inventory deduction with batch-level precision
        *   Integration with document archive
        *   **Supplier Account Statements (v3.0 - October 2025):** Fixed critical bugs where supplier statements showed incorrect titles (displaying "customer" instead of "supplier"), corrected accounting logic (purchases = debit to supplier, payments = credit), and updated all variable references to properly distinguish suppliers from customers. Added supplier_id column to documents table via database migration to properly track supplier-related documents for accurate statement generation
*   **Financial Vouchers (v7.0 - October 2025):** 
    *   Unified voucher system for both receipts (سند قبض) and payments (سند صرف)
    *   Automatic voucher numbering with format VCH-YYYY-NNN (e.g., VCH-2025-001)
    *   Support for cash, check, bank transfer, and credit card payment methods
    *   Automatic synchronization with customer/supplier balances and document archive
    *   Professional print-ready voucher templates with company logo and signatures
    *   Amount-to-words conversion in Arabic for both YER and USD
    *   Advanced filtering and search capabilities
    *   File attachment support (PDF, images) for voucher documentation
    *   Automatic document archiving for customer account statements integration
*   **Electronic Archive:** Digital storage, classification, indexing, and easy retrieval of all documents.
*   **Reporting & Statistics (v10.0 - October 2025):** 
    *   **Advanced Analytics Dashboard:** Professional dashboard with comprehensive financial insights and interactive visualizations
    *   **Key Performance Indicators:** Premium cards showing debts receivable (لنا), debts payable (علينا), monthly profits, and sales statistics with gradient designs
    *   **Interactive Charts (Chart.js):** 
        *   Doughnut chart for debt distribution across currencies (YER/USD) without hard-coded conversion rates
        *   Bar chart comparing monthly sales vs. purchases by currency
        *   Smart tooltips with proper currency formatting (ريال for YER, $ for USD)
    *   **Real-Time Metrics:** Secondary cards displaying total customers, suppliers, products, and low-stock alerts
    *   **Latest Transactions Table:** Professional table showing recent financial movements with color-coded status indicators
    *   **Accurate Monthly Calculations:** SQL queries properly filter by both month and year (EXTRACT for MONTH and YEAR) ensuring historical data doesn't skew current-month KPIs
*   **Security:** Implements password hashing (bcrypt), secure sessions with CSRF protection, activity logging, and SQL Injection prevention via PDO Prepared Statements.
*   **UI/UX Decisions:**
    *   **RTL Design:** Fully optimized for Arabic with Right-to-Left layout.
    *   **Loading Screen:** Professional loading screen displayed during form submissions, login, data processing, and page transitions.
    *   **Account Statements (v3.0 - October 2025):** Redesigned for professional business standards, including company info, statement number, issue date, clear customer information, improved transaction table (debits/credits), and signature sections. Print formatting for A4 is optimized to ensure all summary and closing elements appear on the last page.
        *   **Enhanced Balance Summary:** Professional balance summary with clear visual indicators showing whether the balance is "in our favor" (لنا) or "owed by us" (علينا)
        *   **Customer Statements:** Positive balance = لنا (customer owes us) shown in green ✅, Negative balance = علينا (we owe customer) shown in red ⚠️
        *   **Supplier Statements:** Positive balance = علينا (we owe supplier) shown in red ⚠️, Negative balance = لنا (supplier owes us) shown in green ✅
        *   **Dual Currency Display:** Separate sections for YER and USD with color-coded indicators and clear explanations
    *   **Company Logo Management:** Enhanced settings page for uploading, previewing, and deleting company logos (JPG, PNG, GIF, SVG, max 2MB). The logo appears on account statements and printouts.
    *   **Customer Management:** Modification of customer information via pop-up forms, with customer deletion disabled to protect historical data.
    *   **Navigation:** Reorganized sidebar menu with clear, color-coded sections for Inventory, Sales, and Financial Vouchers.
    *   **Inventory UI:** Includes statistics, filtering by warehouse, color-coded expiry alerts, and source tracking badges showing whether items came from purchases (📦), opening stock (📝), or returns (🔄).
    *   **Sales UI:** Advanced filtering, real-time sales statistics, and professional print invoices.
    *   **Purchases UI (v8.0):** Complete purchases section with invoice listing, filtering, detailed view, and returns management integrated into the main navigation.
    *   **Warehouse Creation:** Professional pop-up form for easily adding new warehouses with comprehensive fields.
*   **System Design:**
    *   **Database Schema:** Key tables include `users`, `customers`, `suppliers`, `products`, `warehouses`, `inventory`, `invoices`, `invoice_items`, `vouchers`, `documents`, `activity_logs`, and `settings`.
    *   **Currency Handling:** Primary currency is Yemeni Rial (YER), secondary is US Dollar (USD), with a configurable default exchange rate (1 USD = 1500 YER).
    *   **Critical Security Fixes (Returns System):** 
        *   **v2.0:** Robust backend validation to prevent client-side tampering, ensuring product origin, quantity limits, and recalculating prices from trusted database values.
        *   **v3.0 (Oct 2025):** Enhanced return amount validation to prevent returning amounts exceeding the original invoice total. System now calculates total previous returns and ensures (previous returns + current return) ≤ original invoice total, with detailed error messages showing available returnable amount.
        *   **v8.0 (Oct 2025 - Purchase Returns):** Per-product cumulative return validation ensures that total returned quantities (including previous returns) never exceed original purchase quantities. Inventory deduction uses primary key-based updates to prevent accidental multi-row modifications, maintaining data integrity across concurrent operations.

## External Dependencies
*   **Database:** PostgreSQL (specifically, Neon PostgreSQL is integrated)
*   **Server Environment:** PHP Built-in Server (for local development/testing)
*   **Frontend Libraries:** Standard HTML5, CSS3, JavaScript (no specific third-party frontend frameworks mentioned beyond core web technologies).