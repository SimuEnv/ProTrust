USE Reliability
GO

/****** Object:  Table [dbo].[overbooking_rates_100]    Script Date: 1/20/2018 4:58:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[overbooking_rates_fail](
	[time] [bigint] NOT NULL,
	[machine_id] [bigint] NULL,
	[event_type] [int] NOT NULL,
	[cpu_request] [float] NULL,
	[memory_request] [float] NULL,
	[cpu_over_rate] [float] NULL,
	[memory_over_rate] [float] NULL,
	[cpu_request_total] [float] NULL,
	[memory_request_total] [float] NULL,
	[host_cpu_capacity] [float] NULL,
	[host_memory_capacity] [float] NULL
) ON [PRIMARY]
GO


