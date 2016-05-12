CREATE OR REPLACE PACKAGE BODY TAG.app_meetme AS
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

 PROCEDURE meetme_set_interested_bits (
                                        pkey            in integer,
                                        table_index     in integer,
                                        user_id         in number,
                                        user_rated      in number,
                                        bits_to_set     in number,
                                        bits_to_clear   in number,
                                        interest_bits   out number
                                      ) as
  -- Dynamic SQL.
  exclude_table number:= table_index+1;
  meetme_table varchar2(50) := 'app_meetme_t' || table_index ||'_p' || pkey;
  meetme_view varchar2(50);
  mSql varchar2(1000);
  uSql varchar2(1000);
  -- Local vars.
  is_new_row char(1);
 begin

    begin
     if exclude_table > 5 then
	exclude_table:=0;
     end if;

    meetme_view:='app_meetme_t' ||table_index||'_p'|| pkey||'_view';


      mSql := 'SELECT interested FROM (SELECT   interested ,
                                 interested_uid AS ouid, date_modified,
                                 ROW_NUMBER () OVER (PARTITION BY interested_uid ORDER BY date_modified DESC) rn1
                            FROM ' || meetme_view || '
                           WHERE user_id = :user_id and
                                 interested_uid = :user_rated
                        ORDER BY date_modified DESC)
                 WHERE rn1 = 1';
      execute immediate mSql
      into interest_bits
      using user_id, user_rated;
      is_new_row := 'N';

    exception
    when no_data_found
    then
      interest_bits := 0;
      is_new_row := 'Y';

    end;

    if bits_to_set > 0 then
      interest_bits := interest_bits + bits_to_set - bitand( interest_bits, bits_to_set );
    end if;

    if is_new_row != 'Y' and bits_to_clear > 0 then
      interest_bits := interest_bits - bitand( interest_bits, bits_to_clear );
    end if;

    if(is_match(interest_bits))
    THEN
        meetme_table :=  'app_meetme_matches_p' || pkey;
    END IF;

    uSql := ' update ' || meetme_table ||
            ' set interested=:bits, date_modified=sysdate ' ||
            ' where user_id=:user_id ' ||
            '       and interested_uid=:user_rated';
    execute immediate uSql
    using interest_bits, user_id, user_rated;

    IF sql%ROWCOUNT = 0
    THEN
       BEGIN
       mSql := ' insert into ' || meetme_table || ' ( user_id, interested_uid, interested, date_modified ) ' ||
               ' values ( :user_id, :user_rated, :bits, sysdate )';
       execute immediate mSql
       using user_id, user_rated, interest_bits;
       exception
           when DUP_VAL_ON_INDEX
           then
               execute immediate uSql
               using user_id, user_rated, interest_bits;
       end;
    END IF;

    COMMIT;
 end meetme_set_interested_bits;

 PROCEDURE meetme_update_interest(
                                    pkey            in integer,
                                    table_index     in integer,
                                    user_id         in number,
                                    otheruid        in number,
                                    interested      in number
                                 ) AS
    mSql varchar2(1000);
    meetme_table varchar2(50) := 'app_meetme_t' || table_index ||'_p' || pkey;

 BEGIN


      if(is_match(interested))
        THEN
            meetme_table :=  'app_meetme_matches_p' || pkey;
      END IF;

      mSql := 'UPDATE ' || meetme_table || '
               SET interested = :interested,
                   date_modified = sysdate
               WHERE user_id = :user_id
                  AND interested_uid = :otheruid';

      execute immediate mSql
      using interested,user_id, otheruid;

      IF sql%ROWCOUNT = 0
      THEN
        mSql := ' insert  INTO ' || meetme_table ||
                ' ( user_id, interested_uid, interested, date_modified ) ' ||
                ' values ( :user_id, :otheruid, :bits, sysdate )';
        execute immediate mSql
        using user_id, otheruid, interested;
      END IF;

      COMMIT;

 END meetme_update_interest;

 /**
     This function translates bits and returns
     true if a match otherwise false
 */
 FUNCTION is_match(
                       bits     in    NUMBER
                   ) RETURN BOOLEAN AS
    interest_in_bit  NUMBER;
    interest_of_bit  NUMBER;

 BEGIN

        interest_in_bit := 2;
        interest_of_bit := 4;

        if(bitand(bits,interest_in_bit) = interest_in_bit AND
           bitand(bits,interest_of_bit) = interest_of_bit)
        THEN
           return  true;
        END IF;
        return false;
 END is_match;

 PROCEDURE meetme_clear_bits(
                               pkey            in integer,
                               user_id         in number,
                               otheruid        in number,
                               bits_to_clear   in number
                            ) AS
 BEGIN


       EXECUTE IMMEDIATE 'UPDATE app_meetme_matches_p' || pkey || '
                          SET interested = interested - BITAND(interested, :bits_to_clear)
                          WHERE     user_id = :user_id
                                AND
                                    interested_uid = :otheruid'
       USING bits_to_clear, user_id,   otheruid;

       COMMIT;

 END;

END app_meetme;
/