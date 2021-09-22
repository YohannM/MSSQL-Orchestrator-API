
/****** Object:  Table [dbo].[RPA_OrchestratorAPI_FailedJobLaunching]    Script Date: 7/23/2021 9:09:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RPA_OrchestratorAPI_FailedJobLaunching](
	[Organization] [nvarchar](200) NULL,
	[ProcessName] [varchar](800) NOT NULL,
	[ProcessPathFromRootFolder] [varchar](1000) NOT NULL,
	[LastLaunchTry] [datetime] NOT NULL,
	[LastResultCode] [int] NOT NULL,
	[LastResponse] [varchar](8000) NOT NULL,
	[LastPostData] [varchar](8000) NULL
) ON [PRIMARY]
GO


