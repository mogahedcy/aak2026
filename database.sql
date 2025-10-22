-- نظام إدارة Ahmed Abdulqader Company
-- قاعدة البيانات PostgreSQL

-- جدول المستخدمين
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    role VARCHAR(20) DEFAULT 'user',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول العملاء
CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    city VARCHAR(50),
    tax_number VARCHAR(50),
    opening_balance_yer DECIMAL(15,2) DEFAULT 0,
    opening_balance_usd DECIMAL(15,2) DEFAULT 0,
    current_balance_yer DECIMAL(15,2) DEFAULT 0,
    current_balance_usd DECIMAL(15,2) DEFAULT 0,
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول الموردين
CREATE TABLE IF NOT EXISTS suppliers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    city VARCHAR(50),
    tax_number VARCHAR(50),
    opening_balance_yer DECIMAL(15,2) DEFAULT 0,
    opening_balance_usd DECIMAL(15,2) DEFAULT 0,
    current_balance_yer DECIMAL(15,2) DEFAULT 0,
    current_balance_usd DECIMAL(15,2) DEFAULT 0,
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول المخازن
CREATE TABLE IF NOT EXISTS warehouses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(200),
    manager VARCHAR(100),
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول الفئات
CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول المنتجات
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    category_id INTEGER REFERENCES categories(id),
    description TEXT,
    unit VARCHAR(20) DEFAULT 'قطعة',
    purchase_price_yer DECIMAL(15,2) DEFAULT 0,
    purchase_price_usd DECIMAL(15,2) DEFAULT 0,
    sale_price_yer DECIMAL(15,2) DEFAULT 0,
    sale_price_usd DECIMAL(15,2) DEFAULT 0,
    min_stock_level INTEGER DEFAULT 0,
    expiry_alert_days INTEGER DEFAULT 30,
    barcode VARCHAR(50),
    image VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول المخزون
CREATE TABLE IF NOT EXISTS inventory (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    warehouse_id INTEGER REFERENCES warehouses(id),
    quantity DECIMAL(10,2) DEFAULT 0,
    expiry_date DATE,
    batch_number VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_id, warehouse_id, batch_number)
);

-- جدول الفواتير
CREATE TABLE IF NOT EXISTS invoices (
    id SERIAL PRIMARY KEY,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    invoice_type VARCHAR(20) DEFAULT 'sale', -- sale, purchase, return
    customer_id INTEGER REFERENCES customers(id),
    supplier_id INTEGER REFERENCES suppliers(id),
    invoice_date DATE NOT NULL,
    due_date DATE,
    currency VARCHAR(3) DEFAULT 'YER',
    subtotal DECIMAL(15,2) DEFAULT 0,
    discount DECIMAL(15,2) DEFAULT 0,
    tax DECIMAL(15,2) DEFAULT 0,
    total DECIMAL(15,2) DEFAULT 0,
    paid_amount DECIMAL(15,2) DEFAULT 0,
    remaining_amount DECIMAL(15,2) DEFAULT 0,
    exchange_rate DECIMAL(10,2) DEFAULT 1,
    warehouse_id INTEGER REFERENCES warehouses(id),
    payment_method VARCHAR(50),
    status VARCHAR(20) DEFAULT 'pending',
    notes TEXT,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول تفاصيل الفواتير
CREATE TABLE IF NOT EXISTS invoice_items (
    id SERIAL PRIMARY KEY,
    invoice_id INTEGER REFERENCES invoices(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id),
    quantity DECIMAL(10,2) NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    discount DECIMAL(15,2) DEFAULT 0,
    tax DECIMAL(15,2) DEFAULT 0,
    total DECIMAL(15,2) NOT NULL,
    batch_number VARCHAR(50),
    expiry_date DATE,
    notes TEXT
);

-- جدول سندات القبض والصرف
CREATE TABLE IF NOT EXISTS vouchers (
    id SERIAL PRIMARY KEY,
    voucher_number VARCHAR(50) UNIQUE NOT NULL,
    voucher_type VARCHAR(20) NOT NULL, -- receipt, payment
    date DATE NOT NULL,
    customer_id INTEGER REFERENCES customers(id),
    supplier_id INTEGER REFERENCES suppliers(id),
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'YER',
    exchange_rate DECIMAL(10,2) DEFAULT 1,
    amount_in_other_currency DECIMAL(15,2),
    payment_method VARCHAR(50),
    check_number VARCHAR(50),
    check_date DATE,
    bank_name VARCHAR(100),
    reference_number VARCHAR(50),
    notes TEXT,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول المستندات
CREATE TABLE IF NOT EXISTS documents (
    id SERIAL PRIMARY KEY,
    document_type VARCHAR(50) NOT NULL,
    reference_id INTEGER,
    file_name VARCHAR(255),
    file_path VARCHAR(255),
    file_size INTEGER,
    uploaded_by INTEGER REFERENCES users(id),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول سجل النشاطات
CREATE TABLE IF NOT EXISTS activity_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    action VARCHAR(100),
    details TEXT,
    ip_address VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول الإعدادات
CREATE TABLE IF NOT EXISTS settings (
    id SERIAL PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إدخال بيانات افتراضية
INSERT INTO settings (setting_key, setting_value) VALUES 
    ('company_name', 'Ahmed Abdulqader Company'),
    ('company_location', 'Sana''a'),
    ('company_year', '2015-2025'),
    ('exchange_rate_yer_usd', '1500'),
    ('tax_percentage', '0'),
    ('logo', '')
ON CONFLICT (setting_key) DO NOTHING;

-- إنشاء مستخدم افتراضي (admin / admin123)
INSERT INTO users (username, password, full_name, email, role, is_active) 
VALUES ('admin', '$2y$10$mnKAHtdHa9cAV8OQYyZYCu1haQpA8jNNAo.a4G5O5ZGTgx22mNWAS', 'المدير العام', 'admin@company.com', 'admin', true)
ON CONFLICT (username) DO NOTHING;

-- إنشاء مخزن افتراضي
INSERT INTO warehouses (name, location, manager) 
VALUES ('المخزن الرئيسي', 'صنعاء', 'المدير العام')
ON CONFLICT DO NOTHING;

-- إنشاء فئة افتراضية
INSERT INTO categories (name, description) 
VALUES ('عام', 'فئة افتراضية للمنتجات')
ON CONFLICT DO NOTHING;
