
/****** Object:  StoredProcedure [dbo].[RPA_OrchestratorAPI_RefreshTokens]    Script Date: 7/23/2021 9:13:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Yohann Marmonier
-- Create date: 12.07.2021
-- Description:	Requests for new accessToken and RefreshToken using
--				the actual refreshToken in RPA_OrchestratorApiCredentials.
--				Update it in the table using sym/asym encryption.
-- =============================================
CREATE   PROCEDURE [dbo].[RPA_OrchestratorAPI_RefreshTokens]
	@organization varchar(200),
	@accessToken varchar(6000) OUT
AS
BEGIN

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
	DECLARE @clientID VARCHAR(100);
	DECLARE @clientSecret VARCHAR(100);
	DECLARE @scope VARCHAR(3000);


	-- Get the API Credentials

	OPEN SYMMETRIC KEY SymKey_OrchestratorAPI
			DECRYPTION BY CERTIFICATE RPA_OrchestratorApiCertificate;

	SELECT TOP 1 
		   @clientID = ClientID,
		   @clientSecret = CAST(DecryptByKey(ClientSecret) AS varchar(100)),
		   @scope = Scope
	FROM dbo.RPA_OrchestratorApi_Assets
	WHERE Organization = @organization;

	CLOSE SYMMETRIC KEY SymKey_OrchestratorAPI;


	--Setting post params

	SET @contentType = 'application/x-www-form-urlencoded';
	SET @postData = 'grant_type=client_credentials&client_id=' + @clientID 
					+ '&client_secret=' + @clientSecret
					+ '&scope=' + @scope;
	SET @url = 'https://cloud.uipath.com/identity_/connect/token';
	SELECT @contLength = DATALENGTH(@postData);


	-- Opening  the connection.

	EXEC @ret = sp_OACreate 'MSXML2.ServerXMLHTTP', @token OUT;


	-- Sending the request.

	EXEC @ret = sp_OAMethod @token, 'open', NULL, 'POST', @url, 'false';
	EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Content-Length', @contLength;
	EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Content-type', @contentType;
	EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Accept', '*/*';
	EXEC @ret = sp_OAMethod @token, 'send', NULL, @postData;

	
	-- Handling the response.

	EXEC @ret = sp_OAGetProperty @token, 'status', @status OUT;
	EXEC @ret = sp_OAGetProperty @token, 'statusText', @statusText OUT;
	EXEC @ret = sp_OAGetProperty @token, 'responseText', @responseText OUT;


	-- Closing the connection.

	EXEC @ret = sp_OADestroy @token;


	-- Parsing tokens

	SET @accessToken = JSON_VALUE(@responseText, '$.access_token');


	-- Showing result

	PRINT '[RPA_OrchestratorAPI_RefreshTokens] request returned a ' + @status;

	IF @status = '200'
       RETURN(0)
	ELSE 
       -- Insertion job � lancer
	   RETURN(1)

END
GO


