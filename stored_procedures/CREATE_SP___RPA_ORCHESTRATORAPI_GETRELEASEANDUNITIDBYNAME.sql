
/****** Object:  StoredProcedure [dbo].[RPA_OrchestratorAPI_GetReleaseKeyAndUnitIDByName]    Script Date: 7/23/2021 9:11:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Yohann Marmonier
-- Create date: 15.07.21
-- Description:	Requests the release Key to Orchestrator API
--				from a process name
-- =============================================
CREATE   PROCEDURE [dbo].[RPA_OrchestratorAPI_GetReleaseKeyAndUnitIDByName] 
	-- Add the parameters for the stored procedure here
	@processName varchar(800),
	@organization varchar(200),
	@processPathFromEnvFolder varchar(1000),
	@releaseKey varchar(500) OUT,
	@organizationUnitId BIGINT OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @accessToken VARCHAR(6000);
	DECLARE @authHeader VARCHAR(6100);
	DECLARE @url VARCHAR(1024);
	DECLARE @ret INT;
	DECLARE @status VARCHAR(32);
	DECLARE @token INT;
	DECLARE @statusText VARCHAR(32);
	DECLARE @responseText VARCHAR(8000);
	DECLARE @tenant VARCHAR(200);
	DECLARE @envFolder  VARCHAR(200);

    -- Get a new AccessToken

	EXEC dbo.RPA_OrchestratorAPI_RefreshTokens
			@organization = @organization,
			@accessToken = @accessToken OUT;

	-- Get the AcessToken Credentials

	OPEN SYMMETRIC KEY SymKey_OrchestratorAPI
			DECRYPTION BY CERTIFICATE RPA_OrchestratorApiCertificate;

	SELECT @tenant = Tenant, @envFolder = RootFolder
	FROM dbo.RPA_OrchestratorApi_Assets
	WHERE Organization = @organization;

	CLOSE SYMMETRIC KEY SymKey_OrchestratorAPI;

	--Setting post params

	SET @authHeader = 'Bearer ' + @accessToken;
	SET @url = 'https://cloud.uipath.com/' + @organization + '/' + @tenant + '/orchestrator_/odata/Releases?$filter=Name eq ''' + @processName +  '''';


	-- Opening  the connection.

	EXEC @ret = sp_OACreate 'MSXML2.ServerXMLHTTP', @token OUT;


	-- Sending the request.
	if @envFolder <> ''
		SET @processPathFromEnvFolder = @envFolder + '/' + @processPathFromEnvFolder;


	EXEC @ret = sp_OAMethod @token, 'open', NULL, 'GET', @url, 'false';
	EXEC @ret = sp_OAMethod @token, 'SetRequestHeader', NULL, 'X-UIPATH-FolderPath', @processPathFromEnvFolder;
	EXEC @ret = sp_OAMethod @token, 'SetRequestHeader', NULL, 'Authorization', @authHeader;
	EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Accept', '*/*';
	EXEC @ret = sp_OAMethod @token, send, NULL, ''

	
	-- Handling the response.

	EXEC @ret = sp_OAGetProperty @token, 'status', @status OUT;
	EXEC @ret = sp_OAGetProperty @token, 'statusText', @statusText OUT;
	EXEC @ret = sp_OAGetProperty @token, 'responseText', @responseText OUT;


	-- Closing the connection.

	EXEC @ret = sp_OADestroy @token;

	-- Extracting the Key

	SET @releaseKey = JSON_VALUE(@responseText, '$.value[0].Key');
	SET @organizationUnitId = JSON_VALUE(@responseText, '$.value[0].OrganizationUnitId');

	-- Showing result

	PRINT '[RPA_OrchestratorAPI_GetReleaseKeyAndUnitIDByName] request returned a ' + @status;

	IF @status = '200'
       RETURN(0)
	ELSE 
       -- Insertion job � lancer
	   RETURN(1)

END
GO


