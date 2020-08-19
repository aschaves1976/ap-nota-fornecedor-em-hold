CREATE OR REPLACE TRIGGER XXVEN_AP_INVGLBATTRBI_TRG
BEFORE INSERT ON AP_PAYMENT_SCHEDULES_ALL  REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW

DECLARE
  lv_global_attribute1   ap_invoices_all.global_attribute1%TYPE;
  lv_payment_method_code ap_payment_schedules_all.payment_method_code%TYPE;
  lv_hold_flag           ap_payment_schedules_all.hold_flag%TYPE;
  user_xcep              EXCEPTION;
  PRAGMA EXCEPTION_INIT( user_xcep, -20001 );
BEGIN
  IF :new.amount_remaining > 0 THEN
    SELECT
             'BOLETO' payment_method_code
           , 'SIM'    global_attribute1
           , 'Y'      hold_flag
      INTO
             lv_payment_method_code
           , lv_global_attribute1
           , lv_hold_flag
      FROM   ap_invoices_all        aia 
    WHERE 1=1
      AND aia.invoice_id               = :new.invoice_id
      AND aia.invoice_type_lookup_code = 'STANDARD'
      AND aia.source                   = 'PROCFIT'
    ;
    --
    :new.hold_flag           := lv_hold_flag;
    :new.payment_method_code := lv_payment_method_code;
    --
  ELSIF :new.amount_remaining < 0 THEN
    SELECT
             'BORDERO' payment_method_code
           , 'NÃO'    global_attribute1
           --, 'N'      hold_flag
      INTO
             lv_payment_method_code
           , lv_global_attribute1
           --, lv_hold_flag
      FROM   ap_invoices_all        aia 
    WHERE 1=1
      AND aia.invoice_id               = :new.invoice_id
      AND aia.invoice_type_lookup_code = 'CREDIT'
      AND aia.source                   = 'PROCFIT'
    ;
    --
    :new.payment_method_code := lv_payment_method_code;
    --
  END IF;
  --
  UPDATE ap_invoices_all aia
    SET  global_attribute1 = lv_global_attribute1
  WHERE 1=1
    AND aia.invoice_id               = :new.invoice_id
    AND aia.invoice_type_lookup_code = 'STANDARD'
    AND aia.source                   = 'PROCFIT'
  ;
EXCEPTION
  WHEN OTHERS THEN
    raise user_xcep;
END XXVEN_AP_INVGLBATTRBI_TRG;
/