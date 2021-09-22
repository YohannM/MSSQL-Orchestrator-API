
/****** Object:  StoredProcedure [dbo].[RPA_OrchestratorAPI_StartJob]    Script Date: 7/23/2021 9:14:23 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Yohann Marmonier
-- Create date: 13.07.2021
-- Description:	Starts Jobs whose process name is in arguments
-- =============================================
CREATE   PROCEDURE [dbo].[RPA_OrchestratorAPI_StartJob]
	-- Add the parameters for the stored procedure here
	@processName varchar(800),
	@organization varchar(200)='vertivco',
	@processPathFromEnvFolder varchar(1000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @accessToken VARCHAR(6000);
	DECLARE @responseText VARCHAR(8000);
	DECLARE @contLength BIGINT;
	DECLARE @contentType VARCHAR(64);
	DECLARE @postData VARCHAR(8000);
	DECLARE @responseXML VARCHAR(8000);
	DECLARE @ret INT;
	DECLARE @status NVARCHAR(32);
	DECLARE @statusText NVARCHAR(32);
	DECLARE @token INT;
	DECLARE @url NVARCHAR(256);
	DECLARE @authHeader VARCHAR(6100);
	DECLARE @releaseKey VARCHAR(500);
	DECLARE @tenant VARCHAR(200);
	DECLARE @organizationUnitId BIGINT;


	-- Get Credentials

	OPEN SYMMETRIC KEY SymKey_OrchestratorAPI
			DECRYPTION BY CERTIFICATE RPA_OrchestratorApiCertificate;

	SELECT @tenant = Tenant
	FROM dbo.RPA_OrchestratorApi_Assets
	WHERE Organization = @organization;

	CLOSE SYMMETRIC KEY SymKey_OrchestratorAPI;


	-- Get a new AccessToken

	EXEC dbo.RPA_OrchestratorAPI_RefreshTokens
		@organization = @organization,
		@accessToken = @accessToken OUT;


	-- Get releaseKey

	EXEC	[dbo].[RPA_OrchestratorAPI_GetReleaseKeyAndUnitIDByName]
		@processName = @processName,
		@organization = @organization,
		@processPathFromEnvFolder = @processPathFromEnvFolder,
		@releaseKey = @releaseKey OUT,
		@organizationUnitId = @organizationUnitId OUT


	--Setting post params

	SET @authHeader = 'Bearer ' + @accessToken
	SET @contentType = 'application/json';
	SET @postData = '{
						"startInfo": {
							"ReleaseKey": "' + ISNULL(@releaseKey, 'null') + '",
							"Strategy": "ModernJobsCount",
							"JobsCount": 1,
							"InputArguments": "{}"
						}
					}';
	SET @url = 'https://cloud.uipath.com/' + @organization + '/' + @tenant + '/orchestrator_/odata/Jobs/UiPath.Server.Configuration.OData.StartJobs';
	SELECT @contLength = DATALENGTH(@postData);


	-- Opening  the connection.

	EXEC @ret = sp_OACreate 'MSXML2.ServerXMLHTTP', @token OUT;
	


	-- Sending the request.

	EXEC @ret = sp_OAMethod @token, 'open', NULL, 'POST', @url, 'false';
	EXEC @ret = sp_OAMethod @token, 'SetRequestHeader', NULL, 'Authorization', @authHeader;
	EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Content-Length', @contLength;
	EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Content-type', @contentType;
	EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Accept', '*/*';
	EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'X-UIPATH-OrganizationUnitId', @organizationUnitId;
	EXEC @ret = sp_OAMethod @token, 'send', NULL, @postData;

	
	-- Handling the response.

	EXEC @ret = sp_OAGetProperty @token, 'status', @status OUT;
	EXEC @ret = sp_OAGetProperty @token, 'statusText', @statusText OUT;
	EXEC @ret = sp_OAGetProperty @token, 'responseText', @responseText OUT;


	-- Closing the connection.

	EXEC @ret = sp_OADestroy @token;


	-- Showing result

	PRINT '[RPA_OrchestratorAPI_StartJob] request returned a ' + @status;

	IF @status = '201'
       RETURN(0)
	ELSE 
       INSERT INTO RPA_OrchestratorApi_FailedJobLaunching ([Organization], [ProcessName], [ProcessPathFromRootFolder],
								[LastLaunchTry], [LastResultCode], [LastResponse], [LastPostData])
		   VALUES (@organization, @processName, @processPathFromEnvFolder, 
								getdate(), @status, @responseText, @postData);
	   RETURN(1)

    
END
GO


