# MSSQL-Orchestrator-API

To deploy this project on your SQL Server, you'll need two steps : 

- Register an external app on Orchestrator

- Run the SQL Code


## 1 - Register an external app on Orchestrator


In order to request Orchestrator Cloud API, you'll need to **register your client as an external application** on your Orchestrator.

Connect on your Orchestrator and go under **Admin -> External Applications** :

HERE


Then click on  HERE


Then fill in **The Application Name**. 
Then chose **Confidential Application**.

Then click on HERE


Select **Orchestrator API Access** and go under **Application Scope** (that's important to determine which OAuth workflow your app will use to authenticate) :

HERE


Then select the above Scopes and click Save :
- **OR.Jobs.Write** 
- **OR.Execution.Read**

Leave the **Redirect Url** field empty.

Then Save your new External App. 
**A window appears with your app ID and Secret, keep it, we'll need it for next steps.**


## 2 - Run the SQL Code

### Getting scripts from Github :

Then clone or download this project.

### Edit config files :

When it's done, go edit the two files : 

* **config/CREATE_MASTER_KEY.sql** :
  * Replace **YOUR_DATABASE** by your database name

* **config/FILL_TABLE.sql**
   * Replace **YOUR_ORCHESTRATOR_ORGANIZATION_NAME** by your organization name

  * Replace **YOUR_ORCHESTRATOR_TENANT_NAME** by your tenant
  * Replace **YOUR_EXTERNAL_APP_ID** by the app id from step one
  * Replace **YOUR_EXTERNAL_APP_SECRET** by the app secret from step one

### Run tables and stored procedures creation :

Now, you just have to run either : 
- ```create_on_mssql.cmd``` from a terminal if you authenticate to MSSQL under SQL Server Authentication
- or ```create_on_mssql_windows_auth.cmd``` from a terminal if you authenticate to MSSQL under Windows Integrated Authentication


**Note : to run those scripts, you'll need :**
* **EXECUTE privilege** on those four system procedures (you'll need it to start jobs later too):
  * **sp_OACreate**
  * **sp_OAMethod**
  * **sp_OAGetProperty**
  * **sp_OADestroy**
- **CONTROL** permission on the database.
- **CREATE CERTIFICATE** permission on the database. Only Windows logins, SQL Server logins, and application roles can own certificates. Groups and roles cannot own certificates. 


### That's it, you're ready to start UiPath processes from MSSQL !

Now you can test it running :
``` 
EXEC	[RPA_OrchestratorAPI_StartJob]
		@processName = N'YOUR_PROCESS_NAME',
		@organization = N'YOUR_ORGANIZATION_NAME',
		@processPathFromEnvFolder = N'PATH_TO_PROCESS'
```

With PATH_TO_PROCESS beeing the complete path to the folder where your process is.
E.g. Staging/TestLoggingSite for a process located here :

HERE

That's it ! 
Don't hesitate to ask questions if it bugs or if some points are unclear.
