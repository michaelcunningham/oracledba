SET SERVEROUTPUT ON SIZE 100000;

prompt Starting NOV_CR19964ChangeTestEmailAddresses

UPDATE cm_contact_info
SET    contact_info_detail = contact_info_detail || 'TEST'
WHERE  contact_info_detail IS NOT NULL
  AND  LOWER(contact_info_detail) NOT LIKE '%@thedoctors.com'
  AND  contact_info_detail NOT LIKE '%TEST'
  AND  contact_info_type_id = 'EA';
  
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

