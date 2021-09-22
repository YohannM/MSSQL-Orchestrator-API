

/****** Object:  StoredProcedure [dbo].[RPA_OrchestratorAPI_UpdateAppSecret]    Script Date: 7/23/2021 9:14:45 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Yohann Marmonier
-- Create date: 13.07.2021
-- Description:	Takes the new secret in argument and encrypt it 
--				into RPA_OrchestratorApiCredentials
-- =============================================
CREATE PROCEDURE [dbo].[RPA_OrchestratorAPI_UpdateAppSecret] 
	@organization varchar(200),
	@clientSecret VARCHAR(100) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    OPEN SYMMETRIC KEY SymKey_OrchestratorAPI
        DECRYPTION BY CERTIFICATE RPA_OrchestratorApiCertificate;

	UPDATE dbo.RPA_OrchestratorApi_Credentials 
	SET ClientSecret = EncryptByKey (Key_GUID('SymKey_OrchestratorAPI'), @clientsecret)
	WHERE Organization = @organization;

	CLOSE SYMMETRIC KEY SymKey_OrchestratorAPI;
	
END
GO


