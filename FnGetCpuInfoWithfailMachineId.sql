USE [Reliability]
GO

/****** Object:  UserDefinedFunction [dbo].[FnGetCpuInfoWithMachineId]    Script Date: 1/20/2018 4:50:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Yousef
-- Description:	Returns the most recent resource
-- info for a machine and time specified
-- =============================================
CREATE FUNCTION [dbo].[FnGetCpuInfoWithfailMachineId](@mach_id bigint, @tm bigint) 
RETURNS float
AS
BEGIN 
	declare @cpu_info float
	select top 1 @cpu_info = cpu from failure_host_machine_events where machine_id = @mach_id and [time] < @tm order by [time] desc
	return @cpu_info
END
GO


