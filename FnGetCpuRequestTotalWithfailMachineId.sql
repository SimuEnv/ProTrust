USE Reliability
GO

/****** Object:  UserDefinedFunction [dbo].[FnGetCpuRequestTotalWithMachineId]    Script Date: 1/20/2018 5:04:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








-- =============================================
-- Author:		Yousef
-- Description:	Returns the most recent total CPU
-- request for a machine and time specified
-- =============================================
CREATE FUNCTION [dbo].[FnGetCpuRequestTotalWithfailMachineId](@mach_id bigint, @tm bigint) 
RETURNS float
AS
BEGIN 
	declare @cpu_request_total float
	select top 1 @cpu_request_total = cpu_request_total from overbooking_rates_fail where machine_id = @mach_id and [time] <= @tm order by [time] desc
	return @cpu_request_total
END








GO


