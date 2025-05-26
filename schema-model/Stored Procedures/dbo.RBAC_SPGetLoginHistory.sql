SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[RBAC_SPGetLoginHistory]
(
	@FromDate		Datetime,
	@ToDate			Datetime,
	@Users			Varchar(20),
	@UserCode		Varchar(25),
	@Purpose		Char(1) ='D' -- S --> Summary , D -> Detail
)
As
/**********************************************************************************************************************************************************
	Created By	:	Shammas TP
	Created On	:	01.08.2024
	Project		:	SPARCIM
	Purpose		:	To fetch login history Details
	Test		:	Exec RBAC_SPGetLoginHistory @FromDate='2025-03-16',@ToDate='2025-03-18',@Users='',@UserCode='GIT',@Purpose='S'
**********************************************************************************************************************************************************/
Begin

	Set NoCount On
	Set Transaction Isolation Level Read UnCommitted
	
	If(@Purpose='D')
	Begin
		Select Row_Number() Over(Order By H.Time Desc,H.UserCode) as SlNo,(L.LOCATION+' - '+L.DESCRIPTION) as Location, H.UserCode,U.UserName,
		D.DepartmentCode as Department,Format( H.Time, 'dd-MM-yyyy hh:mm:ss tt') as LoginTime 
		From GTL_LoginHistory H(Nolock) Inner Join GTL_USers U(Nolock) On(U.UserCode=H.UserCode)
		inner join GTL_Location L (Nolock) on U.LOCATIONID=L.LOCATIONID
		Left Outer Join GTL_Department D(Nolock) On(D.DepartmentID=U.Department)
		Where H.UserCode=Case When @Users='' Then H.UserCode Else @Users End
		and Convert(varchar(10),H.Time,23)>=@FromDate 
		and Convert(varchar(10),H.Time,23)<=@ToDate
	End
	Else
	Begin
		SELECT DISTINCT
		ROW_NUMBER() OVER(ORDER BY COUNT(*) DESC) as SlNo,(L.LOCATION+' - '+L.DESCRIPTION) as Location,
		H.UserCode,
		MAX(U.UserName) as UserName,
		COUNT(*) as Count
		FROM GTL_LoginHistory H(Nolock) 
		INNER JOIN GTL_USers U(Nolock) ON U.UserCode = H.UserCode
		inner join GTL_Location L (Nolock) on U.LOCATIONID=L.LOCATIONID
		WHERE H.UserCode = CASE WHEN @Users = '' THEN H.UserCode ELSE @Users END
		AND CONVERT(varchar(10), H.Time, 23) >= @FromDate 
		AND CONVERT(varchar(10), H.Time, 23) <= @ToDate
		GROUP BY H.UserCode,L.LOCATION,L.DESCRIPTION
		order by count desc
	End

	Select '' as SlNo,'' UserCode,'' UserName,'' as Department,'' as LoginTime

	Select '' as HiddenCols,'' as RightAlignCols,'N' as HTMLOutput

	SELECT'<html><header><img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTh5dX8hbusCfKkLhQFasGj5Ro1P2gVV-FGcQ&s">'+
	+'Geojit Financial Services Limited (GFSL)</header></html>' as HTMLHeader,

	'LoginHistory.xlsx' as FileName,'1|LoginHistory' 

	Set Transaction Isolation Level Read Committed 
	Set NoCount Off

End
GO
