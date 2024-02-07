USE Reliability
GO

/****** Object:  UserDefinedFunction [dbo].[FnGetMachinetypeWithMachineID]    Script Date: 1/20/2018 5:05:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Yousef Alsenani
-- Create date: 12/08/2016
-- Description:	Returns the most recent cpu over
-- booking rate for a machine and time specified
-- =============================================
CREATE FUNCTION [dbo].[FnGetMachinetypeWithfailMachineID](@mach_id bigint) 
RETURNS float
AS
BEGIN 
	declare @machine_type int
	select @machine_type = machine_type from google_machine_type_fail where machine_id = @mach_id 
	return @machine_type
END





GO


