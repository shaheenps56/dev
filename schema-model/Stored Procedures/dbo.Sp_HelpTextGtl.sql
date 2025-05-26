SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
--Exec Sp_HelpTextGtl spsparc_toclientfrompool
--sp_helptext spsparc_toclientallocation
--drop proc Sp_HelpTextGtl
Create Proc [dbo].[Sp_HelpTextGtl](@ObjectName Varchar(256))
As
Begin
		set nocount on
		declare @Def varchar(max)
		select @Def=OBJECT_DEFINITION(OBJECT_ID(@ObjectName)) 
		if @Def is null
		begin
			raiserror('Invalid object',16,1)
		end 
		Declare @DefLen int 
		set @DefLen =Len(@Def)
		Create table #Temp(slno int identity(1,1) primary key,DefScript Varchar(8000))
		Declare @Pos int,@Linelen Int,@NewPos int
		Set @Pos=1
		set @Linelen=0
		Set @NewPos=0		
		While @DefLen>1
		Begin
			Select @Linelen= case when @DefLen>250 then 250 else @DefLen end			
			Select @NewPos=  Charindex(char(10),@Def,@Pos+@Linelen)
			if @NewPos>0 Set @Linelen=@NewPos-@Pos+1			
			Insert into #Temp(DefScript) select SUBSTRING(@Def,@Pos, @Linelen)
			Set @Pos=@Pos+@Linelen
			Set @DefLen=@DefLen-@Linelen
		End
		Select DefScript " " From #Temp	order by slno asc
		drop table #Temp
END
GO
