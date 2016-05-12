BEGIN

-- Inserting new policies into OOB_POLICY_BALANCE table.

	INSERT
	INTO	oob_policy_balance( a00_pnum ) 
	SELECT	DISTINCT a00_pnum
	FROM	pcommon
	WHERE	a54_bto_type <> 'A'
	MINUS
	SELECT	DISTINCT a00_pnum 
	FROM	oob_policy_balance;

	UPDATE	oob_policy_balance
	SET	processed = 0, current_oob = 'N'
	WHERE	a00_pnum IN (	SELECT     DISTINCT a00_pnum
				FROM       precap_history
				WHERE      TRUNC( b04_dbcycle_date ) > TRUNC( SYSDATE - 6 ) );
--      12/05/2002 SN:Begin: Vista Integration SQA 406
--	DELETE	
--	FROM	out_of_bal_dbcommon
--	WHERE	a00_pnum IN (	SELECT	a00_pnum
--				FROM	oob_policy_balance
--				WHERE	processed = 0
--				AND	current_oob = 'N');
--      12/05/2002 SN:End: Vista Integration SQA 406

	DELETE	
	FROM	out_of_bal_precap_history
	WHERE	a00_pnum IN (	SELECT	a00_pnum
				FROM	oob_policy_balance
				WHERE	processed = 0
				AND	current_oob = 'N');

	DELETE	
	FROM	out_of_bal_ptrans
	WHERE	a00_pnum IN (	SELECT	a00_pnum
				FROM	oob_policy_balance
				WHERE	processed = 0
				AND	current_oob = 'N');

	DELETE	
	FROM	out_of_bal_pcoverage
	WHERE	a00_pnum IN (	SELECT	a00_pnum
				FROM	oob_policy_balance
				WHERE	processed = 0
				AND	current_oob = 'N');
--      12/05/2002 SN:Begin: Vista Integration SQA 406
--	DELETE	
--	FROM	out_of_bal_dbreceipts
--	WHERE	a00_pnum IN (	SELECT	a00_pnum
--				FROM	oob_policy_balance
--				WHERE	processed = 0
--				AND	current_oob = 'N');

--	DELETE	
--	FROM	out_of_bal_dbcharge
--	WHERE	a00_pnum IN (	SELECT	a00_pnum
--				FROM	oob_policy_balance
--				WHERE	processed = 0
--				AND	current_oob = 'N');

--	DELETE	
--	FROM	out_of_bal_dbsuspense
--	WHERE	a00_pnum IN (	SELECT	a00_pnum
--				FROM	oob_policy_balance
--				WHERE	processed = 0
--				AND	current_oob = 'N');
--      12/05/2002 SN:End: Vista Integration SQA 406

	COMMIT;

	bal_global.initial_balance;
	
--      12/05/2002 SN:Begin: Vista Integration SQA 406
--	UPDATE	oob_policy_balance
--	SET	current_oob = 'Y'
--	WHERE	a00_pnum IN (	SELECT	DISTINCT a00_pnum
--				FROM	out_of_bal_dbcommon
--				UNION
--				SELECT	DISTINCT a00_pnum
--				FROM	out_of_bal_pcoverage
--				UNION
--				SELECT	DISTINCT a00_pnum
--				FROM	out_of_bal_precap_history
--				UNION
--				SELECT	DISTINCT a00_pnum
--				FROM	out_of_bal_ptrans
--				UNION
--				SELECT	DISTINCT a00_pnum
--				FROM	out_of_bal_dbcharge
--				UNION
--				SELECT	DISTINCT a00_pnum
--				FROM	out_of_bal_dbreceipts
--				UNION
--				SELECT	DISTINCT a00_pnum
--				FROM	out_of_bal_dbsuspense
--			    );
--      12/05/2002 SN:End: Vista Integration SQA 406
	UPDATE	oob_policy_balance
	SET	current_oob = 'Y'
	WHERE	a00_pnum IN (	SELECT	DISTINCT a00_pnum
				FROM	out_of_bal_pcoverage
				UNION
				SELECT	DISTINCT a00_pnum
				FROM	out_of_bal_precap_history
				UNION
				SELECT	DISTINCT a00_pnum
				FROM	out_of_bal_ptrans
			   );
	COMMIT;

END;
/

