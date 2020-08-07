CREATE OR REPLACE TRIGGER XXVEN_AP_INVGLBATTRBI_TRG
BEFORE INSERT ON AP_PAYMENT_SCHEDULES_ALL  REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
WHEN
  (     new.payment_method_code = 'BOLETO'
    AND new.amount_remaining    > 0
  )

DECLARE
  lv_global_attribute1   ap_invoices_all.global_attribute1%TYPE;
BEGIN
  SELECT   pvs.global_attribute1
    INTO   lv_global_attribute1
    FROM   ap_invoices_all        aia
         , ap_supplier_sites_all  pvs
  WHERE 1=1
    AND pvs.vendor_site_id           = aia.vendor_site_id
    AND pvs.vendor_id                = aia.vendor_id
    AND aia.invoice_id               = :new.invoice_id
    AND aia.invoice_type_lookup_code = 'STANDARD'
    AND aia.source                   = 'PROCFIT'
  ;
  UPDATE ap_invoices_all aia
    SET  global_attribute1 = lv_global_attribute1
  WHERE 1=1
    AND aia.invoice_id               = :new.invoice_id
    AND aia.invoice_type_lookup_code = 'STANDARD'
    AND aia.source                   = 'PROCFIT'
  ;
  :new.hold_flag := lv_global_attribute1;
EXCEPTION
  WHEN OTHERS THEN
  :new.hold_flag := :new.hold_flag; 
END XXVEN_AP_INVGLBATTRBI_TRG;
/