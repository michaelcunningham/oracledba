CREATE OR REPLACE PACKAGE BODY TAG.appmeetmespotlight AS

PROCEDURE use_spotlight (
	userid_in IN NUMBER,
	out_var OUT NUMBER
) IS
	remaining_views NUMBER(15,0);
	queryRem VARCHAR2(1000);
	updateRem VARCHAR2(1000);
  p NUMBER (15,0);
BEGIN
  IF userid_in is null THEN
		out_var := -1;
		RETURN;
  END IF;
  p := userid_in MOD 64;
	queryRem := 'SELECT REMAINING_VIEWS
			INTO :remaining_views
			FROM APP_MEETME_SPOTLIGHT_P'  || p ||
			' WHERE USER_ID = :userid_in
			FOR UPDATE';
	updateRem := 'UPDATE APP_MEETME_SPOTLIGHT_P'  || p ||
			' SET REMAINING_VIEWS = :remaining_views - 1
			WHERE USER_ID = :userid_in';
	BEGIN
		EXECUTE IMMEDIATE queryRem
		INTO remaining_views
		USING userid_in;
	EXCEPTION
		WHEN NO_DATA_FOUND
		THEN
			out_var := -1;
			ROLLBACK;
			RETURN;
	END;
	IF(remaining_views = 0)
		THEN
		out_var := -1;
		ROLLBACK;
		RETURN;
	END IF;
	EXECUTE IMMEDIATE updateRem
	USING remaining_views, userid_in;
	out_var := remaining_views - 1;
	COMMIT;
END use_spotlight;

PROCEDURE give_spotlights (
	userid_in IN NUMBER,
	spotlight_count IN NUMBER
) IS
	remaining_views NUMBER(15,0);
	upsql VARCHAR2(1000);
  insql VARCHAR2(1000);
	numrows NUMBER(5);
  p NUMBER (15,0);
BEGIN
  IF userid_in is null THEN
		RETURN;
	END IF;
  p := userid_in MOD 64;
	upsql := 'UPDATE APP_MEETME_SPOTLIGHT_P'  || p ||
			' SET REMAINING_VIEWS = REMAINING_VIEWS + :spotlight_count
			WHERE USER_ID = :userid_in';
	EXECUTE IMMEDIATE upsql
	USING spotlight_count, userid_in;
	numrows := SQL%rowcount;
	IF numrows = 0 THEN
		insql := 'INSERT INTO APP_MEETME_SPOTLIGHT_P'  || p ||
			' (USER_ID, REMAINING_VIEWS)
			VALUES (:userid_in, :spotlight_count)';
		BEGIN
    EXECUTE IMMEDIATE insql
		USING userid_in, spotlight_count;
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX
        THEN
        EXECUTE IMMEDIATE upsql
        USING spotlight_count, userid_in;
    END;

	END IF;
END give_spotlights;
END appmeetmespotlight;
/