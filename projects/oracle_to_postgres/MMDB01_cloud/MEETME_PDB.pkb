CREATE OR REPLACE PACKAGE BODY TAG.MEETME_PDB AS
/******************************************************************************
   NAME:       MEETME_PDB
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        6/2/2008             1. Created this package body.
******************************************************************************/


 PROCEDURE update_meetme_play( inPkey         IN NUMBER,
                            inUserId       IN NUMBER) AS
   tablename VARCHAR2(64);
   ssql VARCHAR2(1000);
   numrows  NUMBER(5);
 BEGIN
    tableName := 'app_meetme_resp_p' || inPkey;

    ssql := 'UPDATE ' || tableName ||
            ' set score = 1, date_modified = sysdate
              WHERE user_id = :userId';

    EXECUTE IMMEDIATE ssql
    USING
        inUserId;

    numrows := SQL%rowcount;
    --if no rows were selected then insert a row for this user.
    IF numrows = 0 THEN

        ssql := 'INSERT INTO ' || tableName ||
                '    (USER_ID, SCORE)
                 VALUES
                     (:inUserId, 1)';
        EXECUTE IMMEDIATE ssql
        USING
            inUserId;

    END IF;

END update_meetme_play;


PROCEDURE update_meetme_play2( inPkey         IN NUMBER,
                            inUserId       IN NUMBER) AS
   tablename VARCHAR2(64);
   ssql VARCHAR2(1000);
   numrows  NUMBER(5);
 BEGIN
    -- original meetme responsiveness
    tableName := 'app_meetme_resp_p' || inPkey;

    ssql := 'UPDATE ' || tableName ||
            ' set score = 1, date_modified = sysdate
              WHERE user_id = :userId';

    EXECUTE IMMEDIATE ssql
    USING
        inUserId;

    numrows := SQL%rowcount;
    --if no rows were selected then insert a row for this user.
    IF numrows = 0 THEN

        ssql := 'INSERT INTO ' || tableName ||
                '    (USER_ID, SCORE)
                 VALUES
                     (:inUserId, 1)';
        EXECUTE IMMEDIATE ssql
        USING
            inUserId;

    END IF;

    -- new meetme responsiveness
    tableName := 'app_meetme_resp2_p' || inPkey;

    ssql := 'UPDATE ' || tableName ||
            ' set yes_clicks = 0, no_clicks = 0, data_modified = sysdate
              WHERE user_id = :userId';
    EXECUTE IMMEDIATE ssql
    USING
        inUserId;

    numrows := SQL%rowcount;
    --if no rows were selected then insert a row for this user.
    IF numrows = 0 THEN

        ssql := 'INSERT INTO ' || tableName ||
                '    (USER_ID, yes_clicks,no_clicks, data_modified)
                 VALUES
                     (:inUserId, 0, 0,sysdate)';
        EXECUTE IMMEDIATE ssql
        USING
            inUserId;

    END IF;
END update_meetme_play2;



PROCEDURE update_meetme_resp( inPkey IN NUMBER, inUserId IN NUMBER) AS
   tablename VARCHAR2(64);
   ssql VARCHAR2(1000);
   numrows  NUMBER(5);
 BEGIN
    numrows:=0;
    tableName := 'app_meetme_resp_p' || inPkey;

    ssql := 'UPDATE ' || tableName ||
            ' set score = score / (score + 1), date_modified = sysdate
              WHERE user_id = :inUserId';
   EXECUTE IMMEDIATE ssql
    USING inUserId;

    numrows := SQL%rowcount;
    --if no rows were selected then insert a row for this user.
	IF numrows = 0 THEN
   	 	ssql := 'INSERT into ' || tableName ||
            	'(user_id, score, date_modified) values (:inUserId, 1 / (1 + 1), sysdate)';
     		EXECUTE IMMEDIATE ssql
     		USING inUserId;
    	end if;

END update_meetme_resp;



PROCEDURE update_meetme_resp2( inPkey IN NUMBER, inUserId IN NUMBER, click IN VARCHAR2 ) AS
   tablename VARCHAR2(64);
   tablename2 VARCHAR2(64);
   ssql VARCHAR2(1000);
   ssql2 VARCHAR2(1000);
   numrows  NUMBER(15);
   origScore NUMBER(6,5);
 BEGIN
    -- original meetme responsiveness
    numrows:=0;
    tableName := 'app_meetme_resp_p' || inPkey;

    ssql := 'UPDATE ' || tableName ||
            ' set score = score / (score + 1), date_modified = sysdate
              WHERE user_id = :inUserId';
    EXECUTE IMMEDIATE ssql
      USING inUserId;

    numrows := SQL%rowcount;
    --if no rows were selected then insert a row for this user.
	  IF numrows = 0 THEN
   	 	ssql := 'INSERT into ' || tableName ||
            	'(user_id, score, date_modified) values (:inUserId, 1 / (1 + 1), sysdate)';
     		EXECUTE IMMEDIATE ssql
     		USING inUserId;
    end if;

    -- new meetme responsiveness
    numrows:=0;
    tableName2 := 'app_meetme_resp2_p' || inPkey;
    IF ( click = 'Y' ) THEN
      ssql := 'UPDATE ' || tableName2 ||
              ' set yes_clicks = yes_clicks + 1, data_modified = sysdate
                WHERE user_id = :inUserId';
    ELSE --( click == 'N' )
      ssql := 'UPDATE ' || tableName2 ||
              ' set no_clicks = no_clicks + 1, data_modified = sysdate
                WHERE user_id = :inUserId';
    END IF;

    EXECUTE IMMEDIATE ssql
      USING inUserId;

    numrows := SQL%rowcount;
    --if no rows were selected then insert a row for this user.
	  IF numrows = 0 THEN
      origScore := -1;

      ssql2 := 'SELECT score FROM ' || tableName || ' WHERE user_id = :inUserId';

      EXECUTE IMMEDIATE ssql2
            INTO origscore
            USING inUserId;

      IF origScore > -1 THEN
        ssql := 'INSERT into ' || tableName2 ||
                '(user_id, yes_clicks, no_clicks, data_modified) values (:inUserId, 0,
                1 / :origScore, sysdate)';
          EXECUTE IMMEDIATE ssql
            USING inUserId, origScore;
      END IF;
    end if;

END update_meetme_resp2;


-- rel 8_20
PROCEDURE meetme_set_interested_bits (
  pkey in integer,
  user_id in number,
  user_rated in number,
  bits_to_set in number,
  bits_to_clear in number,
  interest_bits out number
) is
  -- Dynamic SQL.
  meetme_table varchar2(255) := 'app_meetme_p' || pkey;
  meetme_select_query varchar2(255) :=
    'select interested ' ||
    'from ' || meetme_table || ' ' ||
    'where user_id=:user_id ' ||
    'and interested_uid=:user_rated';
  meetme_dml_query varchar2(255);
  -- Local vars.
  is_new_row char(1);
begin
  begin
    dbms_output.put_line( meetme_table );
    dbms_output.put_line( meetme_select_query );
    execute immediate meetme_select_query
    into interest_bits
    using user_id, user_rated;
    is_new_row := 'N';
    meetme_dml_query :=
      'update ' || meetme_table || ' ' ||
      'set interested=:bits, date_modified=sysdate ' ||
      'where user_id=:user_id ' ||
      'and interested_uid=:user_rated';
  exception
    when no_data_found
    then
      interest_bits := 0;
      is_new_row := 'Y';
      meetme_dml_query :=
        'insert into ' || meetme_table || ' ( user_id, interested_uid, interested, date_modified ) ' ||
        'values ( :user_id, :user_rated, :bits, sysdate )';
  end;
  if bits_to_set > 0 then
    interest_bits := interest_bits + bits_to_set - bitand( interest_bits, bits_to_set );
  end if;
  if is_new_row != 'Y' and bits_to_clear > 0 then
    interest_bits := interest_bits - bitand( interest_bits, bits_to_clear );
  end if;
  if is_new_row = 'Y' then
    execute immediate meetme_dml_query
    using user_id, user_rated, interest_bits;
  else
    execute immediate meetme_dml_query
    using interest_bits, user_id, user_rated;
  end if;
end meetme_set_interested_bits;
END MEETME_PDB;
/