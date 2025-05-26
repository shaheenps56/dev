SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--Select * from dbo.GTL_Split(',','a,b,c,d',null,null,null,null) T
CREATE FUNCTION [dbo].[GTL_Split](
	@Delimiter char(1),
	@String1 varchar(max),
	@String2 varchar(max) = '',
	@String3 varchar(max) = '',
	@String4 varchar(max) = '',
	@String5 varchar(max) = ''
)
RETURNS @Results TABLE 
(
	Item1 varchar(max),
	Item2 varchar(max),
	Item3 varchar(max),
	Item4 varchar(max),
	Item5 varchar(max)
)
/*
	Created By	:	Dipu V P,Anil S
	Use:For splitting more than One string for creting a table 
*/
AS
BEGIN
   DECLARE @INDEX1 INT,@INDEX2 INT,@INDEX3 INT,@INDEX4 INT,@INDEX5 INT
    DECLARE @Slice1 NVarchar(4000),@Slice2 NVarchar(4000),@Slice3 NVarchar(4000),@Slice4 NVarchar(4000),@Slice5 NVarchar(4000)
    -- HAVE TO SET TO 1 SO IT DOESNT EQUAL ZERO FIRST TIME IN LOOP
    SELECT @INDEX1 = 1
	select @INDEX2 = 1
	select @INDEX3 = 1
	select @INDEX4 = 1
	select @INDEX5 = 1
    -- following line added 10/06/04 as null
    --      values cause issues
    IF @String1 IS NULL RETURN
    WHILE @INDEX1 !=0
    BEGIN
        	-- GET THE INDEX OF THE FIRST OCCURENCE OF THE SPLIT CHARACTER
        	SELECT @INDEX1 = CHARINDEX(@Delimiter,@STRING1)
        	-- NOW PUSH EVERYTHING TO THE LEFT OF IT INTO THE SLICE VARIABLE
        	IF @INDEX1 !=0
        		SELECT @SLICE1 = LEFT(@STRING1,@INDEX1 - 1)
        	ELSE
        		SELECT @SLICE1 = @STRING1
			--String2
			SELECT @INDEX2 = CHARINDEX(@Delimiter,@STRING2)
			IF @INDEX2 !=0
        		SELECT @SLICE2 = LEFT(@STRING2,@INDEX2 - 1)
        	ELSE
        		SELECT @SLICE2 = @STRING2
			--String3
			SELECT @INDEX3 = CHARINDEX(@Delimiter,@STRING3)
			IF @INDEX3 !=0
        		SELECT @SLICE3 = LEFT(@STRING3,@INDEX3 - 1)
        	ELSE
        		SELECT @SLICE3 = @STRING3
			--String4
			SELECT @INDEX4 = CHARINDEX(@Delimiter,@STRING4)
			IF @INDEX4 !=0
        		SELECT @SLICE4 = LEFT(@STRING4,@INDEX4 - 1)
        	ELSE
        		SELECT @SLICE4 = @STRING4
			--String5
			SELECT @INDEX5 = CHARINDEX(@Delimiter,@STRING5)
			IF @INDEX5 !=0
        		SELECT @SLICE5 = LEFT(@STRING5,@INDEX5 - 1)
        	ELSE
        		SELECT @SLICE5 = @STRING5


	-- PUT THE ITEM INTO THE RESULTS SET
        	INSERT INTO @Results(Item1,Item2,ITem3,Item4,ITem5) VALUES(@SLICE1,@SLICE2,@SLICE3,@SLICE4,@SLICE5)
        	-- CHOP THE ITEM REMOVED OFF THE MAIN STRING
        	SELECT @STRING1 = RIGHT(@STRING1,LEN(@STRING1) - @INDEX1)
        	-- BREAK OUT IF WE ARE DONE
        	IF LEN(@STRING1) = 0 BREAK
		
			SELECT @STRING2 = RIGHT(@STRING2,LEN(@STRING2) - @INDEX2)
        	-- BREAK OUT IF WE ARE DONE
        	IF LEN(@STRING2) = 0 BREAK
	
			SELECT @STRING3 = RIGHT(@STRING3,LEN(@STRING3) - @INDEX3)
        	-- BREAK OUT IF WE ARE DONE
        	IF LEN(@STRING3) = 0 BREAK

			SELECT @STRING4 = RIGHT(@STRING4,LEN(@STRING4) - @INDEX4)
        	-- BREAK OUT IF WE ARE DONE
        	IF LEN(@STRING4) = 0 BREAK

			SELECT @STRING5 = RIGHT(@STRING5,LEN(@STRING5) - @INDEX5)
        	-- BREAK OUT IF WE ARE DONE
        	IF LEN(@STRING5) = 0 BREAK
    END
	
return 
END





GO
