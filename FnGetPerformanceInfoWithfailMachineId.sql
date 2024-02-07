USE Reliability
GO

/****** Object:  UserDefinedFunction [dbo].[FnGetPerformanceInfoWithMachineId]    Script Date: 1/20/2018 5:21:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Yousef
-- Description:	Returns the performance of a machine
-- =============================================
CREATE FUNCTION [dbo].[FnGetPerformanceInfoWithfailMachineId](@mach_id bigint, @tm bigint, @cpi float) 
RETURNS float
AS
BEGIN 
	declare @cpu_info float
	declare @memory_info float
	declare @performance float

	-- Assumptions
	declare @instruction_count bigint
	declare @max_clock_time bigint
	declare @mach_clock_time bigint
 
	select top 1 @cpu_info = cpu, @memory_info = memory from [dbo].[failure_host_machine_events] where machine_id = @mach_id and [time] < @tm order by [time] desc

	--500 million
	set @instruction_count = 500000000
	--3Ghz
	set @max_clock_time = 3000000000
	--Each machines speed is different
	set @mach_clock_time = @max_clock_time * @cpu_info
		
	set @performance = (@instruction_count * @cpi * 1.0) / (@mach_clock_time)
	return @performance
END

GO


