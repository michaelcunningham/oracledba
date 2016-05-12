BEGIN
		UPDATE ED_SYSTEM_DOCUMENT
		SET DMG_DOC_ID = NULL
		WHERE DMG_DOC_ID IS NOT NULL;
     
      DBMS_OUTPUT.PUT_LINE( 'ED_SYSTEM_DOCUMENT table had ' || SQL%ROWCOUNT
                || ' rows updated.' );

	COMMIT;
END;
/
