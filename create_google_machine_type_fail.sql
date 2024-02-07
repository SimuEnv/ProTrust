USE Reliability
GO

/****** Object:  Table [dbo].[google_machine_type]    Script Date: 1/20/2018 5:07:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE  [dbo].[google_machine_type_fail](
	[machine_id] [bigint] NOT NULL,
	[machine_type] [bigint] NOT NULL,
	[cpu] [float] NULL,
	[memory] [float] NULL,
 CONSTRAINT [PK_google_machine_type_fail] PRIMARY KEY CLUSTERED 
(
	[machine_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


