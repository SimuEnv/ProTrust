USE Reliability
GO

/****** Object:  UserDefinedFunction [dbo].[FnGetMemoryRequestTotalWithMachineId]    Script Date: 1/20/2018 5:18:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		Yousef
-- Description:	Returns the most recent total memory
-- request for a machine and time specified
-- =============================================
CREATE FUNCTION [dbo].[FnGetMemoryRequestTotalWithfailMachineId](@mach_id bigint, @tm bigint) 
RETURNS float
AS
BEGIN 
	declare @memory_request_total float
	select top 1 @memory_request_total = memory_request_total from [dbo].[overbooking_rates_fail] where machine_id = @mach_id and [time] <= @tm order by [time] desc
	return @memory_request_total
END







GO


