CREATE OR REPLACE FUNCTION TAG.is_match(
                       bits     in    NUMBER  
                   ) RETURN number AS
    interest_in_bit  NUMBER;
    interest_of_bit  NUMBER;                       
 BEGIN
      
        interest_in_bit := 2;
        interest_of_bit := 4;
        
        if(bitand(bits,interest_in_bit) = interest_in_bit AND
           bitand(bits,interest_of_bit) = interest_of_bit) 
        THEN
           return 1;
        END IF;
        return 0;
 END is_match;
/