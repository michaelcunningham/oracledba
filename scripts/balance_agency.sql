set feedback off
set linesize 125
set trimspool on
SET SERVEROUTPUT ON SIZE 100000
--
        truncate table out_of_bal_agent_open_item;
        truncate table  out_of_bal_aoi_history; 
        truncate table out_of_bal_pinstallment;

DECLARE
PROCEDURE balance AS
	CURSOR curCAB IS
		SELECT	DISTINCT a00_pnum, a06_edition
		FROM	agent_open_item
		union
		SELECT	DISTINCT a00_pnum, a06_edition
		FROM	aoi_history;
		
	/*CURSOR curCAB IS
		SELECT	DISTINCT a00_pnum, a06_edition
		FROM	agent_open_item;	*/
		
		
	CURSOR curAoi IS
		SELECT	a00_pnum, a06_edition, created h53_ndate,
			a08_fdate, a09_xdate,
			column_name, rule_id, column_amount,
			derived_amount, deviation_amount
		FROM	out_of_bal_agent_open_item
		ORDER BY a00_pnum, a06_edition, rule_id;
	CURSOR curAH IS
		SELECT	a00_pnum, a06_edition, h53_ndate,
			a08_fdate, a09_xdate,
			column_name, rule_id, column_amount,
			derived_amount, deviation_amount
		FROM	out_of_bal_aoi_history
		ORDER BY a00_pnum, a06_edition, rule_id;
	CURSOR curP IS
		SELECT	a00_pnum, a06_edition, h53_ndate,
			a08_fdate, a09_xdate,
			column_name, rule_id, column_amount,
			derived_amount, deviation_amount
		FROM	out_of_bal_pinstallment
		ORDER BY a00_pnum, a06_edition, rule_id;
	CURSOR curBR IS
		SELECT	RPAD( rule_id, 7 ) || error_description description
		FROM	balance_rule
		WHERE	rule_id IN(
				SELECT	rule_id
				FROM	out_of_bal_agent_open_item )
		UNION
		SELECT	RPAD( rule_id, 7 ) || error_description description
		FROM	balance_rule
		WHERE	rule_id IN(
				SELECT	rule_id
				FROM	out_of_bal_aoi_history )
		UNION
		SELECT	RPAD( rule_id, 7 ) || error_description description
		FROM	balance_rule
		WHERE	rule_id IN(
				SELECT	rule_id
				FROM	out_of_bal_pinstallment )
		ORDER BY 1;


	rCAB	curCAB%ROWTYPE;
	rAoi	curAoi%ROWTYPE;
	rAH	curAH%ROWTYPE;
	rP	curP%ROWTYPE;
	rBR	curBR%ROWTYPE;

	sOutput	VARCHAR2(125);
	nCount	INTEGER := 0;
BEGIN
	OPEN curCAB;
	FETCH curCAB INTO rCAB;
	WHILE curCAB%FOUND LOOP
		bal_global.balance_policy( rCAB.a00_pnum, rCAB.a06_edition );
		bal_global.balance_agency( rCAB.a00_pnum, rCAB.a06_edition );
		FETCH curCAB INTO rCAB;
	END LOOP;
	CLOSE curCAB;
--
	DBMS_OUTPUT.PUT_LINE( 'Report Name                 : Agency Balancing' );
	DBMS_OUTPUT.PUT_LINE( 'This report was created on  : ' || TO_CHAR( SYSDATE, 'MonthDD, YYYY' ) );
	OPEN curAoi;
	FETCH curAoi INTO rAoi;
	IF curAoi%NOTFOUND THEN
		DBMS_OUTPUT.PUT_LINE( CHR(9) );
		DBMS_OUTPUT.PUT_LINE( CHR(9) );
		DBMS_OUTPUT.PUT_LINE( 'No out of balance records found for AGENT_OPEN_ITEM.' );
	ELSE
		DBMS_OUTPUT.PUT_LINE( CHR(9) );
		DBMS_OUTPUT.PUT_LINE( CHR(9) );
		DBMS_OUTPUT.PUT_LINE( CHR(9) || '                                *****  Balancing - AGENT_OPEN_ITEM  *****' );
		DBMS_OUTPUT.PUT_LINE( CHR(9) );
		DBMS_OUTPUT.PUT_LINE( 'Pnum    Edition H53 Date  AOI-Fdate AOI-Xdate Column Name                    Rule   Column Amt  Derived Amt Deviation Amt' );
		DBMS_OUTPUT.PUT_LINE( '------- ------- --------- --------- --------- ------------------------------ ---- ------------ ------------ -------------' );
		WHILE curAoi%FOUND LOOP
			sOutput	:= rAoi.a00_pnum;
			sOutput := sOutput || LPAD( rAoi.a06_edition, 8, ' ' );
			sOutput := sOutput || LPAD( TO_CHAR( rAoi.h53_ndate, 'DD-MON-YY' ), 10, ' ' );
			sOutput := sOutput || LPAD( TO_CHAR( rAoi.a08_fdate, 'DD-MON-YY' ), 10, ' ' );
			sOutput := sOutput || LPAD( TO_CHAR( rAoi.a09_xdate, 'DD-MON-YY' ), 10, ' ' );
			sOutput := sOutput || ' ' || RPAD( rAoi.column_name, 30, ' ' );
			sOutput := sOutput || LPAD( rAoi.rule_id, 5, ' ' );
			sOutput := sOutput || LPAD( TO_CHAR( rAoi.column_amount, '9,999,990.00' ), 13, ' ' );
			sOutput := sOutput || LPAD( TO_CHAR( rAoi.derived_amount, '9,999,990.00' ), 13, ' ' );
			sOutput := sOutput || LPAD( TO_CHAR( rAoi.deviation_amount, '9,999,990.00' ), 14, ' ' );
			DBMS_OUTPUT.PUT_LINE( sOutput );

			FETCH curAoi INTO rAoi;
		END LOOP;
	END IF;
	CLOSE curAoi;
--
	OPEN curAH;
	FETCH curAH INTO rAH;
	IF curAH%NOTFOUND THEN
		DBMS_OUTPUT.PUT_LINE( CHR(9) );
		DBMS_OUTPUT.PUT_LINE( CHR(9) );
		DBMS_OUTPUT.PUT_LINE( 'No out of balance records found for AOI_HISTORY.' );
	ELSE
		DBMS_OUTPUT.PUT_LINE( CHR(9) );
		DBMS_OUTPUT.PUT_LINE( CHR(9) );
		DBMS_OUTPUT.PUT_LINE( CHR(9) );
		DBMS_OUTPUT.PUT_LINE( CHR(9) || '                                  *****  Balancing - AOI_HISTORY  *****' );
		DBMS_OUTPUT.PUT_LINE( CHR(9) );
		DBMS_OUTPUT.PUT_LINE( 'Pnum    Edition H53 Date  AOI-Fdate AOI-Xdate Column Name                    Rule   Column Amt  Derived Amt Deviation Amt' );
		DBMS_OUTPUT.PUT_LINE( '------- ------- --------- --------- --------- ------------------------------ ---- ------------ ------------ -------------' );
		WHILE curAH%FOUND LOOP
			sOutput	:= rAH.a00_pnum;
			sOutput := sOutput || LPAD( rAH.a06_edition, 8, ' ' );
			sOutput := sOutput || LPAD( TO_CHAR( rAH.h53_ndate, 'DD-MON-YY' ), 10, ' ' );
			sOutput := sOutput || LPAD( TO_CHAR( rAH.a08_fdate, 'DD-MON-YY' ), 10, ' ' );
			sOutput := sOutput || LPAD( TO_CHAR( rAH.a09_xdate, 'DD-MON-YY' ), 10, ' ' );
			sOutput := sOutput || ' ' || RPAD( rAH.column_name, 30, ' ' );
			sOutput := sOutput || LPAD( rAH.rule_id, 5, ' ' );
			sOutput := sOutput || LPAD( TO_CHAR( rAH.column_amount, '9,999,990.00' ), 13, ' ' );
			sOutput := sOutput || LPAD( TO_CHAR( rAH.derived_amount, '9,999,990.00' ), 13, ' ' );
			sOutput := sOutput || LPAD( TO_CHAR( rAH.deviation_amount, '9,999,990.00' ), 14, ' ' );
			DBMS_OUTPUT.PUT_LINE( sOutput );

			FETCH curAH INTO rAH;
		END LOOP;
	END IF;
	CLOSE curAH;
--
	OPEN curP;
	FETCH curP INTO rP;
	IF curP%NOTFOUND THEN
		DBMS_OUTPUT.PUT_LINE( CHR(9) );
		DBMS_OUTPUT.PUT_LINE( CHR(9) );
		DBMS_OUTPUT.PUT_LINE( 'No out of balance records found for PINSTALLMENT.' );
	ELSE
		DBMS_OUTPUT.PUT_LINE( CHR(9) );
		DBMS_OUTPUT.PUT_LINE( CHR(9) );
		DBMS_OUTPUT.PUT_LINE( CHR(9) );
		DBMS_OUTPUT.PUT_LINE( CHR(9) || '                                  *****  Balancing - PINSTALLMENT  *****' );
		DBMS_OUTPUT.PUT_LINE( CHR(9) );
		DBMS_OUTPUT.PUT_LINE( 'Pnum    Edition H53 Date  AOI-Fdate AOI-Xdate Column Name                    Rule   Column Amt  Derived Amt Deviation Amt' );
		DBMS_OUTPUT.PUT_LINE( '------- ------- --------- --------- --------- ------------------------------ ---- ------------ ------------ -------------' );
		WHILE curP%FOUND LOOP
			sOutput	:= rP.a00_pnum;
			sOutput := sOutput || LPAD( rP.a06_edition, 8, ' ' );
			sOutput := sOutput || LPAD( TO_CHAR( rP.h53_ndate, 'DD-MON-YY' ), 10, ' ' );
			sOutput := sOutput || LPAD( TO_CHAR( rP.a08_fdate, 'DD-MON-YY' ), 10, ' ' );
			sOutput := sOutput || LPAD( TO_CHAR( rP.a09_xdate, 'DD-MON-YY' ), 10, ' ' );
			sOutput := sOutput || ' ' || RPAD( rP.column_name, 30, ' ' );
			sOutput := sOutput || LPAD( rP.rule_id, 5, ' ' );
			sOutput := sOutput || LPAD( TO_CHAR( rP.column_amount, '9,999,990.00' ), 13, ' ' );
			sOutput := sOutput || LPAD( TO_CHAR( rP.derived_amount, '9,999,990.00' ), 13, ' ' );
			sOutput := sOutput || LPAD( TO_CHAR( rP.deviation_amount, '9,999,990.00' ), 14, ' ' );
			DBMS_OUTPUT.PUT_LINE( sOutput );

			FETCH curP INTO rP;
		END LOOP;
	END IF;
	CLOSE curP;
--
	OPEN curBR;
	FETCH curBR INTO rBR;
	IF curBR%FOUND THEN
		DBMS_OUTPUT.PUT_LINE( CHR(9) );
		DBMS_OUTPUT.PUT_LINE( CHR(9) );
		DBMS_OUTPUT.PUT_LINE( CHR(9) );
		DBMS_OUTPUT.PUT_LINE( CHR(9) );
		DBMS_OUTPUT.PUT_LINE( 'Decription of balancing rules violated.' );
		DBMS_OUTPUT.PUT_LINE( RPAD( '-', 90, '-' ) );
		WHILE curBR%FOUND LOOP
			DBMS_OUTPUT.PUT_LINE( rBR.description );
			FETCH curBR INTO rBR;
		END LOOP;
	END IF;
	CLOSE curBR;
END balance;

BEGIN
	balance;
END;
/

commit;

set feedback on

