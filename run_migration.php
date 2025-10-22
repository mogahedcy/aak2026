<?php
// سكريبت لتنفيذ migration إضافة عمود original_invoice_id
// قم بتشغيله من المتصفح مرة واحدة فقط: http://your-domain/run_migration.php

require_once 'includes/config.php';

echo "<h2>تنفيذ تحديث قاعدة البيانات...</h2>";
echo "<pre>";

try {
    // الخطوة 1: إضافة العمود الجديد
    echo "الخطوة 1: إضافة عمود original_invoice_id...\n";
    $pdo->exec("ALTER TABLE invoices ADD COLUMN IF NOT EXISTS original_invoice_id INTEGER");
    echo "✓ تم بنجاح\n\n";
    
    // الخطوة 2: إضافة قيد المرجعية (Foreign Key)
    echo "الخطوة 2: إضافة قيد المرجعية...\n";
    $pdo->exec("
        DO $$ 
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM pg_constraint 
                WHERE conname = 'fk_original_invoice'
            ) THEN
                ALTER TABLE invoices 
                ADD CONSTRAINT fk_original_invoice 
                FOREIGN KEY (original_invoice_id) 
                REFERENCES invoices(id) 
                ON DELETE SET NULL;
            END IF;
        END $$;
    ");
    echo "✓ تم بنجاح\n\n";
    
    // الخطوة 3: إضافة فهرس لتسريع الاستعلامات
    echo "الخطوة 3: إضافة فهرس للأداء...\n";
    $pdo->exec("CREATE INDEX IF NOT EXISTS idx_invoices_original_invoice_id ON invoices(original_invoice_id)");
    echo "✓ تم بنجاح\n\n";
    
    // الخطوة 4: تحديث المرتجعات الموجودة
    echo "الخطوة 4: ربط المرتجعات القديمة بالفواتير الأصلية...\n";
    $stmt = $pdo->exec("
        UPDATE invoices AS ret
        SET original_invoice_id = orig.id
        FROM invoices AS orig
        WHERE ret.invoice_type = 'return'
          AND ret.original_invoice_id IS NULL
          AND ret.notes = 'مرتجع من الفاتورة: ' || orig.invoice_number
          AND orig.invoice_type = 'sale'
    ");
    echo "✓ تم تحديث $stmt مرتجع\n\n";
    
    // الخطوة 5: عرض ملخص
    echo "الخطوة 5: ملخص التحديث...\n";
    $summary = $pdo->query("
        SELECT 
            COUNT(CASE WHEN invoice_type = 'return' AND original_invoice_id IS NOT NULL THEN 1 END) as returns_linked,
            COUNT(CASE WHEN invoice_type = 'return' AND original_invoice_id IS NULL THEN 1 END) as returns_unlinked,
            COUNT(CASE WHEN invoice_type = 'return' THEN 1 END) as total_returns
        FROM invoices
    ")->fetch();
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    echo "✓ التحديث اكتمل بنجاح!\n";
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    echo "إجمالي المرتجعات: " . $summary['total_returns'] . "\n";
    echo "المرتجعات المربوطة: " . $summary['returns_linked'] . "\n";
    echo "المرتجعات غير المربوطة: " . $summary['returns_unlinked'] . "\n";
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";
    
    if ($summary['returns_unlinked'] > 0) {
        echo "⚠️ تنبيه: يوجد " . $summary['returns_unlinked'] . " مرتجع غير مربوط.\n";
        echo "يمكنك ربطها يدوياً من خلال صفحة قاعدة البيانات.\n\n";
    }
    
    echo "<strong style='color: green; font-size: 18px;'>✓ النظام جاهز الآن! يمكنك إغلاق هذه النافذة والعودة لصفحة المرتجعات.</strong>\n";
    echo "\n<a href='pages/sales_returns.php' style='display: inline-block; margin-top: 20px; padding: 10px 20px; background: #4CAF50; color: white; text-decoration: none; border-radius: 5px;'>← العودة لصفحة المرتجعات</a>";
    
} catch (Exception $e) {
    echo "\n❌ حدث خطأ: " . $e->getMessage() . "\n";
    echo "\nالرجاء التواصل مع المطور.\n";
}

echo "</pre>";
?>
