USE [Reliability]
GO

/****** Object:  UserDefinedFunction [dbo].[FnGetMemoryInfoWithMachineId]    Script Date: 1/20/2018 5:15:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Faruk Caglar
-- Create date: 08/26/2013
-- Description:	Returns the most recent resource
-- info for a machine and time specified
-- =============================================
CREATE FUNCTION [dbo].[FnGetMemoryInfoWithfailMachineId](@mach_id bigint, @tm bigint) 
RETURNS float
AS
BEGIN 
	declare @memory_info float
	select top 1 @memory_info = memory from [dbo].[failure_host_machine_events] where machine_id = @mach_id and [time] < @tm order by [time] desc
	return @memory_info
END


GO


