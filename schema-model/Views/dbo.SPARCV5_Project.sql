SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE View [dbo].[SPARCV5_Project] AS
Select P.ProjectID,P.Code as Project,P.ShowDropDown,'' as HelpUrl,P.IconUrl,P.IconColor,P.IconClass,P.Active,
P.ParentProjectID, P.SortOrder,P.DefaultProject,P.ExternalProject,P.SelectedColor,P.HoverColor
From GTL_Projects P(Nolock)
GO
