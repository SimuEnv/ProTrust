USE Reliability
GO

/****** Object:  UserDefinedFunction [dbo].[FnGetTotalVMNumberPriortWithMachineId]    Script Date: 1/20/2018 5:44:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FnGetTotalVMtWithfailMachineId](@mach_id bigint, @tm bigint, @event_type int) 
RETURNS float
AS
BEGIN 
	declare @total_vm_number int
	  
 select @total_vm_number =
  CASE @event_type
		  WHEN -1 THEN (select COUNT(*) 
		   from (select distinct job_id, task_index from [dbo].[Failed_hosts_task_usage] where machine_id = @mach_id and sampling_start_time = @tm) as dv)
		  ELSE  
			(select COUNT(*)  from 
				(select distinct te.job_id, te.task_index from [dbo].[Failed_hosts_task_usage] as tu
					inner join [dbo].[failed_hosts_task_event] as te on tu.machine_id = te.machine_id 
					where tu.machine_id = @mach_id and tu.sampling_start_time = @tm
					and te.event_type = @event_type 
					and te.[time]>tu.sampling_start_time and te.[time]<=tu.sampling_end_time) as dv
			)
  END
	
	return @total_vm_number
END








GO


