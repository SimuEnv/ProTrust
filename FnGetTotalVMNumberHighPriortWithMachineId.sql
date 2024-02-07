


ALTER FUNCTION [dbo].[FnGetTotalVMNumberHighPriortWithMachineId](@mach_id bigint, @tm bigint, @event_type int) 
RETURNS float
AS
BEGIN 
	declare @total_vm_number int
	  
 select @total_vm_number =
  CASE @event_type
		  WHEN -1 THEN (select COUNT(*) 
		   from (select distinct job_id, task_index from [dbo].failed_hosts_task_event where machine_id = @mach_id and time = @tm) as dv)
		  ELSE  
			(select COUNT(*)  from 
				(select distinct te.job_id, te.task_index from [dbo].[Failed_hosts_task_usage] as tu
					inner join [dbo].[failed_hosts_task_event] as te on tu.machine_id = te.machine_id 
					where tu.machine_id = @mach_id and tu.sampling_start_time = @tm
					and te.event_type = @event_type
					and te.[time]>tu.sampling_start_time and te.[time]<=tu.sampling_end_time
					and te.[priority] in (9,10,11)) as dv
			
			)
  END
	
	return @total_vm_number
END

























--CREATE FUNCTION [dbo].[FnGetTotalVMNumberHighPriortWithMachineId](@mach_id bigint, @tm bigint, @event_type int) 
--RETURNS float
--AS
--BEGIN 
--	declare @total_vm_number int
	  
-- select @total_vm_number =
--  CASE @event_type
--		  WHEN -1 THEN (select COUNT(*) 
--		   from (select distinct job_id, task_index from [dbo].Failed_hosts_task_usage where machine_id = @mach_id and sampling_start_time = @tm) as dv)
--		  ELSE  
--			(select COUNT(*)  from 
--				(select distinct te.job_id, te.task_index from [dbo].Failed_hosts_task_usage as tu
--					inner join [dbo].[failed_hosts_task_event] as te on tu.machine_id = te.machine_id 
--					where tu.machine_id = @mach_id and tu.sampling_start_time = @tm
--					and te.event_type = @event_type and te.priority in (9,10,11)
--					and te.[time]>tu.sampling_start_time and te.[time]<=tu.sampling_end_time) as dv
--			)
--  END
	
--	return @total_vm_number
--END








GO


