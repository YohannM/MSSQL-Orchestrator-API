BEGIN
	DECLARE @hasMasterKey int;

	SELECT @hasMasterKey = d.is_master_key_encrypted_by_server
	FROM sys.databases AS d
	WHERE d.name = 'YOUR_DATABASE';

	PRINT @hasMasterKey

	IF @hasMasterKey = 0
		BEGIN
			PRINT 'This database doesn''t have a master key, we''ll create one..';
			CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'theMasterKeyPassword123!';
		END

	PRINT 'Creation of the certificate RPA_OrchestratorApiCertificate...';
	CREATE CERTIFICATE RPA_OrchestratorApiCertificate WITH SUBJECT = 'Apps Credentials for API access';

	PRINT 'Creation of the symmetric key SymKey_OrchestratorAPI...';
	CREATE SYMMETRIC KEY SymKey_OrchestratorAPI WITH ALGORITHM = AES_256 ENCRYPTION BY CERTIFICATE RPA_OrchestratorApiCertificate;

	PRINT 'End of keys generation.';
END;