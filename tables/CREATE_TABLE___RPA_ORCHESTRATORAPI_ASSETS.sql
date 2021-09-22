

/****** Object:  Table [dbo].[RPA_OrchestratorApi_Assets]    Script Date: 7/23/2021 9:07:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RPA_OrchestratorApi_Assets](
	[Organization] [nvarchar](200) NOT NULL,
	[Tenant] [nvarchar](200) NOT NULL,
	[RootFolder] [nvarchar](200) NOT NULL,
	[ClientID] [nvarchar](70) NOT NULL,
	[ClientSecret] [varbinary](max) NOT NULL,
	[RefreshDate] [datetime] NOT NULL,
	[Scope] [nvarchar](3000) NOT NULL,
 CONSTRAINT [PK_RPA_OrchestratorApi_Assets] PRIMARY KEY CLUSTERED 
(
	[Organization] ASC,
	[Tenant] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO



