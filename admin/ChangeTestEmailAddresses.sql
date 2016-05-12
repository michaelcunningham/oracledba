SET SERVEROUTPUT ON SIZE 100000;


ALTER TRIGGER cm_contact_info_aiudr_trg DISABLE;  
ALTER TRIGGER cm_contact_info_aiuds_trg DISABLE; 

UPDATE cm_contact_info
SET    contact_info_detail = contact_info_detail || 'TEST'
WHERE  contact_info_detail IS NOT NULL
  AND  LOWER(contact_info_detail) NOT LIKE '%@thedoctors.com'
  AND  contact_info_detail NOT LIKE '%TEST'
  AND  contact_info_type_id = 'EA';

  
ALTER TRIGGER cm_contact_info_aiudr_trg ENABLE;  
ALTER TRIGGER cm_contact_info_aiuds_trg ENABLE; 

UPDATE am_agency
SET    contact_email_addr = contact_email_addr || 'TEST'
WHERE  contact_email_addr IS NOT NULL
  AND  LOWER(contact_email_addr) NOT LIKE '%@thedoctors.com'
  AND  contact_email_addr NOT LIKE '%TEST';

UPDATE am_agency
SET    email_addr = email_addr || 'TEST'
WHERE  email_addr IS NOT NULL
  AND  LOWER(email_addr) NOT LIKE '%@thedoctors.com'
  AND  email_addr NOT LIKE '%TEST';

UPDATE am_agency
SET    edoc_admin_email_addr = edoc_admin_email_addr || 'TEST'
WHERE  edoc_admin_email_addr IS NOT NULL
  AND  LOWER(edoc_admin_email_addr) NOT LIKE '%@thedoctors.com'
  AND  edoc_admin_email_addr NOT LIKE '%TEST';

UPDATE am_producer
SET    email_addr = email_addr || 'TEST'
WHERE  email_addr IS NOT NULL
  AND  LOWER(email_addr) NOT LIKE '%@thedoctors.com'
  AND  email_addr NOT LIKE '%TEST';

UPDATE pa_custom_account_upload
SET    email_address = email_address || 'TEST'
WHERE  email_address IS NOT NULL
  AND  LOWER(email_address) NOT LIKE '%@thedoctors.com'
  AND  email_address NOT LIKE '%TEST';

UPDATE pa_insured_detail_esignature
SET    email_addr = email_addr || 'TEST'
WHERE  email_addr IS NOT NULL
  AND  LOWER(email_addr) NOT LIKE '%@thedoctors.com'
  AND  email_addr NOT LIKE '%TEST';
  
  
  
--	UPDATE aa_sys_config
--	SET    notification_email_addr = notification_email_addr || 'TEST'
--	WHERE  notification_email_addr IS NOT NULL
--	  AND  LOWER(notification_email_addr) NOT LIKE '%@thedoctors.com';

--	UPDATE ed_outbound_document
--	SET    outbound_confirm_email_addr = outbound_confirm_email_addr || 'TEST'
--	WHERE  outbound_confirm_email_addr IS NOT NULL
--    AND  LOWER(outbound_confirm_email_addr) NOT LIKE '%@thedoctors.com';

--	UPDATE em_employee
--	SET    email_addr = email_addr || 'TEST'
--	WHERE  email_addr IS NOT NULL
--    AND  LOWER(email_addr) NOT LIKE '%@thedoctors.com';

--	UPDATE temp_employee
--	SET    email_addr = email_addr || 'TEST'
--	WHERE  email_addr IS NOT NULL
--    AND  LOWER(email_addr) NOT LIKE '%@thedoctors.com';

--	UPDATE v_em_employee
--	SET    email_addr = email_addr || 'TEST'
--	WHERE  email_addr IS NOT NULL
--    AND  LOWER(email_addr) NOT LIKE '%@thedoctors.com';

--	UPDATE v_em_underwriter
--	SET    email_addr = email_addr || 'TEST'
--	WHERE  email_addr IS NOT NULL
--    AND  LOWER(email_addr) NOT LIKE '%@thedoctors.com';


	                 