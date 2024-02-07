USE Reliability
GO

/****** Object:  UserDefinedFunction [dbo].[FnGetMemoryOverRateWithMachineId]    Script Date: 1/20/2018 5:16:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		Yousef
-- Description:	Returns the most recent cpu over
-- booking rate for a machine and time specified
-- =============================================
CREATE FUNCTION [dbo].[FnGetMemoryOverRateWithfailMachineId](@mach_id bigint, @tm bigint) 
RETURNS float
AS
BEGIN 
	declare @memory_over_rate float
	select top 1 @memory_over_rate = memory_over_rate from [dbo].[overbooking_rates_fail] where machine_id = @mach_id and [time] <= @tm order by [time] desc
	return @memory_over_rate
END







GO


