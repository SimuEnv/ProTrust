/*
	STEP 1: GENERATE OVEBOOKING RATIOS FOR ALL THE MACHINES
	IN THE CLUSTER AND SAVE THESE INFO INTO OVERBOOKING_RATES
	TABLE FOR CONVENIENCE
*/

-- Insert overbooking rates into a temp table	
	declare @temp_machine_events table
	(
		[time] bigint not null,
		machine_id bigint,
		event_type int,
		cpu float,
		memory float,
		processed int
	)
	
	declare @max_task_time bigint
	select @max_task_time = max([time]) from [dbo].[failed_hosts_task_event]

	insert into @temp_machine_events
		-- select top 20000 [time], machine_id, event_type, cpu, memory, 0 as processed from machine_events order by [time]
		-- select * from credit_union_hosts		
		--select [time], machine_id, event_type, cpu, memory, 0 as processed from machine_events where machine_id in (410695, 662219) order by [time]
		select [time], machine_id, event_type, cpu, memory, 0 as processed from machine_events where machine_id in (select h.machine_id from [dbo].[failure_host_machine_events] as h) order by [time]

	-- Add max time as well otherwise it does not get the tasks for those of machines
	-- have not record in machine events other than time 0
	insert into @temp_machine_events
		select @max_task_time, t.machine_id, t.event_type, t.cpu, t.memory, 0 as processed from @temp_machine_events as t
		inner join
		(
			select machine_id, max([time]) as [time] from @temp_machine_events group by machine_id
		) as t_in on t.machine_id = t_in.machine_id and t.[time] = t_in.[time]

	declare @temp_machine_event_time table
	(
		machine_id bigint,
		prev_machine_event_time bigint,
		prev_cpu_request_total float,
		prev_memory_request_total float
	)

	insert into @temp_machine_event_time
		select machine_id, -1 as prev_machine_event_time, 0 as prev_cpu_request_total, 0 as prev_memory_request_total from machine_events group by machine_id

	declare @prev_machine_event_time bigint
	declare @actual_machine_event_time bigint

	declare @machine_id bigint
	declare @machine_event_type int
	declare @host_available_cpu float
	declare @host_available_memory float

	declare @temp_task_events table
	(
		[time] bigint not null,
		job_id bigint,
		task_index int,
		machine_id bigint,
		event_type int,
		cpu_request float,
		memory_request float,
		cpu_request_total float,
		memory_request_total float,
		cpu_over_rate float,
		memory_over_rate float,
		host_cpu_capacity float,
		host_memory_capacity float,
		processed int
	)

	declare @task_event_time bigint
	declare @task_event_type int
	declare @job_id bigint
	declare @task_index int
	declare @cpu_request float
	declare @memory_request float
	declare @cpu_request_prev float
	declare @memory_request_prev float
	declare @cpu_request_total float
	declare @memory_request_total float
	declare @host_cpu_total float
	declare @host_memory_total float

	while (select count(*) from @temp_machine_events where processed = 0) > 0
	begin	
		select top 1 @actual_machine_event_time=[time], @machine_id = machine_id, @machine_event_type=event_type, @host_available_cpu = cpu, @host_available_memory=memory from @temp_machine_events where processed = 0 order by [time] asc
		select @prev_machine_event_time = prev_machine_event_time, @cpu_request_total = prev_cpu_request_total, @memory_request_total = prev_memory_request_total from @temp_machine_event_time where machine_id = @machine_id

		insert @temp_task_events
			select 
				te.[time], min(job_id), min(task_index), min(machine_id), max(te.event_type), sum(cpu_request) as cpu_request, sum(memory_request) as memory_request, 0 as cpu_request_total, 0 as memory_request_total, 0 as cpu_over_rate, 0 as memory_over_rate, 0 as host_cpu_capacity, 0 as host_memory_capacity, 0 as processed  
			from [dbo].[failed_hosts_task_event] as te
			-- Whenever a machine is removed from cluster or has its resources updated overbooking rate changes
			-- therefore consider each period seperately
			where te.machine_id = @machine_id and te.event_type!=0 and te.[time] > @prev_machine_event_time and te.[time] <= @actual_machine_event_time
			group by te.[time]

		while (select count(*) from @temp_task_events where processed = 0) > 0
		begin
			select top 1 @task_event_time = [time], @job_id = job_id, @task_index = task_index, @task_event_type=event_type, @cpu_request=cpu_request, @memory_request=memory_request from @temp_task_events where processed = 0 order by [time] asc

			-- if event type is SUBMIT : Already discarded above
			-- If event type is SCHEDULE then add up
			-- If event type is EVICT, FAIL, FINISH, KILL, LOST then subtract
			-- If event type is UPDATE_RUNNING then add the difference
			-- If event type is UPDATE_PENDING then not necessary to add/subtract
			if @task_event_type = 1
			begin
				set @cpu_request_total = @cpu_request_total + @cpu_request
				set @memory_request_total = @memory_request_total + @memory_request
			end
			else if @task_event_type = 8
			begin
				select * from @temp_task_events
				select top 1 @cpu_request_prev = cpu_request, @memory_request_prev = memory_request from failed_hosts_task_event where [time]<@task_event_time and job_id=@job_id and task_index=@task_index and event_type in (1,8) order by [time] desc

				set @cpu_request_total = @cpu_request_total + (@cpu_request - @cpu_request_prev)
				set @memory_request_total = @memory_request_total + (@memory_request - @memory_request_prev) 				
			end
			else
			begin
				set @cpu_request_total = @cpu_request_total - @cpu_request
				set @memory_request_total = @memory_request_total - @memory_request
			end

			update @temp_task_events set processed = 1 where [time] = @task_event_time and machine_id=@machine_id
			update @temp_task_events set cpu_request_total = @cpu_request_total where [time] = @task_event_time and machine_id=@machine_id
			update @temp_task_events set memory_request_total = @memory_request_total where [time] = @task_event_time and machine_id=@machine_id
			update @temp_task_events set cpu_over_rate = @cpu_request_total/@host_available_cpu where [time] = @task_event_time and machine_id=@machine_id
			update @temp_task_events set memory_over_rate = @memory_request_total/@host_available_memory where [time] = @task_event_time and machine_id=@machine_id
			update @temp_task_events set host_cpu_capacity = @host_available_cpu where [time] = @task_event_time and machine_id=@machine_id
			update @temp_task_events set host_memory_capacity = @host_available_memory where [time] = @task_event_time and machine_id=@machine_id
			
		end

		update @temp_machine_events set processed = 1 where machine_id = @machine_id and [time] = @actual_machine_event_time
		update @temp_machine_event_time set prev_machine_event_time = @actual_machine_event_time, prev_cpu_request_total = @cpu_request_total, prev_memory_request_total = @memory_request_total where machine_id = @machine_id

		insert into  overbooking_rates_fail
			select [time], machine_id, event_type, cpu_request, memory_request, cpu_over_rate, memory_over_rate, cpu_request_total, memory_request_total, host_cpu_capacity, host_memory_capacity from @temp_task_events

		delete from @temp_task_events
	end

	
	-- delete from overbooking_rates
	-- select * from overbooking_rates where machine_id = 662219 order by [time] asc
	-- select machine_id, count(*) from overbooking_rates group by machine_id
	-- select top 200 * from credit_union_training_set_all
	-- select avg(cpu_request) as cpu, avg(memory_request) as memory from task_events where event_type=1 and cpu_request is not null and memory_request is not null order by sampling_start_time
	-- select * from task_events where machine_id = 662219 order by [time] asc
	-- select top 100 * from machine_events where machine_id = 662219
