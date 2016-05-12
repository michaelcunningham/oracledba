CREATE OR REPLACE PACKAGE TAG.MEETME_PDB AS
/******************************************************************************
   NAME:       MEETME_PDB
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        6/2/2008             1. Created this package.
******************************************************************************/
  -- Update/Insert the user's responsiveness score to 1.
 PROCEDURE update_meetme_play( inPkey         IN NUMBER,
                            inUserId       IN NUMBER);

 PROCEDURE update_meetme_play2( inPkey         IN NUMBER,
                            inUserId       IN NUMBER);

 PROCEDURE update_meetme_resp( inPkey         IN NUMBER,
                            inUserId       IN NUMBER);

 PROCEDURE update_meetme_resp2( inPkey         IN NUMBER,
                            inUserId       IN NUMBER,
                            click          IN VARCHAR2);
-- rel 8_20
 PROCEDURE meetme_set_interested_bits (
  pkey in integer,
  user_id in number,
  user_rated in number,
  bits_to_set in number,
  bits_to_clear in number,
  interest_bits out number
);
END MEETME_PDB;
/