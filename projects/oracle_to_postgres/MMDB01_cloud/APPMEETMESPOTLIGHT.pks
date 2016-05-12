CREATE OR REPLACE PACKAGE TAG.appmeetmespotlight AS

PROCEDURE use_spotlight (
	userid_in IN NUMBER,
	out_var OUT NUMBER
);
PROCEDURE give_spotlights (
	userid_in IN NUMBER,
	spotlight_count IN NUMBER
);
END appmeetmespotlight;
/