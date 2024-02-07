USE Reliability
GO

/****** Object:  UserDefinedFunction [dbo].[FnGetCpuOverRateWithMachineId]    Script Date: 1/20/2018 5:02:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		Yousef
-- Description:	Returns the most recent cpu over
-- booking rate for a machine and time specified
-- =============================================
CREATE FUNCTION [dbo].[FnGetCpuOverRateWithfailMachineId](@mach_id bigint, @tm bigint) 
RETURNS float
AS
BEGIN 
	declare @cpu_over_rate float
	select top 1 @cpu_over_rate = cpu_over_rate from overbooking_rates_fail where machine_id = @mach_id and [time] <= @tm order by [time] desc
	return @cpu_over_rate
END







GO


