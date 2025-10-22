-- إضافة عمود original_invoice_id لربط المرتجعات بالفواتير الأصلية
-- هذا التحديث مطلوب لنظام المرتجعات v3.0
-- تاريخ: أكتوبر 2025

-- الخطوة 1: إضافة العمود الجديد
ALTER TABLE invoices 
ADD COLUMN IF NOT EXISTS original_invoice_id INTEGER;

-- الخطوة 2: إضافة قيد المرجعية (Foreign Key)
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

-- الخطوة 3: إضافة فهرس لتسريع الاستعلامات
CREATE INDEX IF NOT EXISTS idx_invoices_original_invoice_id 
ON invoices(original_invoice_id);

-- الخطوة 4: تحديث المرتجعات الموجودة (إن وجدت) بطريقة آمنة
-- استخدام مطابقة دقيقة بدلاً من LIKE لتجنب المطابقات الخاطئة
-- هذا الجزء اختياري ويعتمد على وجود بيانات سابقة
UPDATE invoices AS ret
SET original_invoice_id = orig.id
FROM invoices AS orig
WHERE ret.invoice_type = 'return'
  AND ret.original_invoice_id IS NULL
  AND ret.notes = 'مرتجع من الفاتورة: ' || orig.invoice_number
  AND orig.invoice_type = 'sale';

-- الخطوة 5: عرض ملخص التحديث
SELECT 
    'Migration Summary' as status,
    COUNT(CASE WHEN invoice_type = 'return' AND original_invoice_id IS NOT NULL THEN 1 END) as returns_linked,
    COUNT(CASE WHEN invoice_type = 'return' AND original_invoice_id IS NULL THEN 1 END) as returns_unlinked_need_manual_review,
    COUNT(CASE WHEN invoice_type = 'return' THEN 1 END) as total_returns
FROM invoices;

-- ملاحظات مهمة:
-- 1. المرتجعات الجديدة ستُربط تلقائياً بالفاتورة الأصلية
-- 2. المرتجعات القديمة التي لم تُربط (returns_unlinked) تحتاج مراجعة يدوية إن وجدت
-- 3. يمكنك ربطها يدوياً بتشغيل: UPDATE invoices SET original_invoice_id = XXX WHERE id = YYY;
