@echo off

echo.
set /p server="Enter the mssql server name you want to connect to (eg: SERVER_NAME\MSSQL_INSTANCE) : "
set /p db="Enter the database name you want to connect to (ex: MY_AWESOME_DB) : "
set /p username="Enter your username for login : "
set /p pwd="Enter you password for login : "

echo.
echo.
echo Testing the connection to your db :
echo.
sqlcmd -S %server% -d %db% -U %username% -P %pwd% -i test/TEST_CONNECTION.sql
echo.
echo If the connection succeeded, we will now create OrchestratorApi tables and procedures
echo on your database. Press Ctrl+C to stop here.
echo.
PAUSE
echo .
echo MSSQL Configuration...
echo.
echo Activating Ole Automations Components :
sqlcmd -S %server% -d %db% -U %username% -P %pwd% -i tables/ACTIVATE_OLE_AUTOMATION_COMPONENTS.sql
echo.
echo Checking Master Key :
sqlcmd -S %server% -d %db% -U %username% -P %pwd% -i tables/CREATE_MASTER_KEY.sql
echo.
echo.
echo Table creation...
echo.
echo Table RPA_ORCHESTRATORAPI_ASSETS :
sqlcmd -S %server% -d %db% -U %username% -P %pwd% -i tables/CREATE_TABLE___RPA_ORCHESTRATORAPI_ASSETS.sql
echo.
echo Filling RPA_ORCHESTRATORAPI_ASSETS with app info :
sqlcmd -S %server% -d %db% -U %username% -P %pwd% -i tables/FILL_TABLE.sql
echo.
echo Table RPA_ORCHESTRATORAPI_FAILEDJOBLAUNCHING :
sqlcmd -S %server% -d %db% -U %username% -P %pwd% -i tables/CREATE_TABLE___RPA_ORCHESTRATORAPI_FAILEDJOBLAUNCHING.sql
echo.
echo.
echo Stored Procedures creation...
echo.
echo SP RPA_ORCHESTRATORAPI_GETRELEASEANDUNITIDBYNAME :
sqlcmd -S %server% -d %db% -U %username% -P %pwd% -i stored_procedures/CREATE_SP___RPA_ORCHESTRATORAPI_GETRELEASEANDUNITIDBYNAME.sql
echo.
echo SP RPA_ORCHESTRATORAPI_REFRESHTOKENS :
sqlcmd -S %server% -d %db% -U %username% -P %pwd% -i stored_procedures/CREATE_SP___RPA_ORCHESTRATORAPI_REFRESHTOKENS.sql
echo.
echo SP RPA_ORCHESTRATORAPI_RETRYFAILEDJOBSLAUNCHS :
sqlcmd -S %server% -d %db% -U %username% -P %pwd% -i stored_procedures/CREATE_SP___RPA_ORCHESTRATORAPI_RETRYFAILEDJOBSLAUNCHS.sql
echo.
echo SP RPA_ORCHESTRATORAPI_STARTJOB :
sqlcmd -S %server% -d %db% -U %username% -P %pwd% -i stored_procedures/CREATE_SP___RPA_ORCHESTRATORAPI_STARTJOB.sql
echo.
echo SP RPA_ORCHESTRATORAPI_UPDATEAPPSECRET :
sqlcmd -S %server% -d %db% -U %username% -P %pwd% -i stored_procedures/CREATE_SP___RPA_ORCHESTRATORAPI_UPDATEAPPSECRET.sql
echo.