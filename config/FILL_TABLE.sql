OPEN SYMMETRIC KEY SymKey_OrchestratorAPI
        DECRYPTION BY CERTIFICATE RPA_OrchestratorApiCertificate;

INSERT INTO [RPA_OrchestratorApi_Assets]
           ([Organization]
           ,[Tenant]
           ,[RootFolder]
           ,[ClientID]
           ,[ClientSecret]
           ,[RefreshDate]
           ,[Scope])
     VALUES
           ('YOUR_ORCHESTRATOR_ORGANIZATION_NAME'
           ,'YOUR_ORCHESTRATOR_TENANT_NAME'
           ,''
           ,'YOUR_EXTERNAL_APP_ID'
           ,EncryptByKey (Key_GUID('SymKey_OrchestratorAPI'), 'YOUR_EXTERNAL_APP_SECRET')
           ,GETDATE()
           ,'OR.Execution.Read OR.Jobs.Write');

CLOSE SYMMETRIC KEY SymKey_OrchestratorAPI;
GO