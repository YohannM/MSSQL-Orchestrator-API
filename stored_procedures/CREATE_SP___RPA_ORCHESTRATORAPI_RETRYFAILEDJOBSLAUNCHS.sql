

/****** Object:  StoredProcedure [dbo].[RPA_OrchestratorAPI_RetryFailedJobsLaunchs]    Script Date: 7/23/2021 9:13:49 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Yohann Marmonier
-- Create date: 16.07.21
-- Description:	Retry failed launching which are 
--				in RPA_OrchestratorAPI_FailedJobLaunching
-- =============================================
CREATE PROCEDURE [dbo].[RPA_OrchestratorAPI_RetryFailedJobsLaunchs] 
	@organization varchar(200)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @myTableTMP TABLE (name varchar(800)); 
	DECLARE @processPathFromEnvFolder varchar(1000);

	INSERT INTO @myTableTMP
    SELECT ProcessName
    FROM   RPA_OrchestratorAPI_FailedJobLaunching
	WHERE Organization = @organization;


	DECLARE cursorJobs CURSOR FOR
	SELECT * FROM @myTableTMP;

	DECLARE @oneJob varchar(800);
	
	OPEN cursorJobs
	FETCH NEXT FROM cursorJobs INTO @oneJob;

	WHILE @@FETCH_STATUS = 0
	BEGIN

		SELECT @processPathFromEnvFolder = processPathFromRootFolder
		FROM RPA_OrchestratorAPI_FailedJobLaunching
		WHERE ProcessName = @oneJob;

		DELETE FROM RPA_OrchestratorAPI_FailedJobLaunching
		WHERE ProcessName = @oneJob;

		EXEC RPA_OrchestratorAPI_StartJob
			@ProcessNAme = @oneJOb,
			@processPathFromEnvFolder = @processPathFromEnvFolder,
			@organization = @organization;

		FETCH NEXT FROM cursorJobs INTO @oneJob
	END

	CLOSE cursorJobs
	DEALLOCATE cursorJobs
END
GO


