# MSSQL-Orchestrator-API

To deploy this project on your SQL Server, you'll need two steps : 

- Register an external app on Orchestrator

- Run the SQL Code


## 1 - Register an external app on Orchestrator


In order to request Orchestrator Cloud API, you'll need to **register your client as an external application** on your Orchestrator.

Connect on your Orchestrator and go under **Admin -> External Applications** :

![image-1d3f9a6e-adcd-4d87-b478-27373961788a](https://user-images.githubusercontent.com/36423985/134393400-85f8a999-acac-4124-824b-e341282ec91d.png)


Then click on  
![image-e40936d9-2abb-49d2-809c-cf42741cd80f](https://user-images.githubusercontent.com/36423985/134393433-8f4cfa01-45e0-48d7-b171-11051aec397a.png)


Then fill in **The Application Name**. 

Then chose **Confidential Application**.

Then click on 

![image-34374990-65c6-4bab-ad21-ca24a4e4fe48](https://user-images.githubusercontent.com/36423985/134393458-7f1311d5-29db-460d-ba23-72d370cab171.png)



Select **Orchestrator API Access** and go under **Application Scope** (that's important to determine which OAuth workflow your app will use to authenticate) :

![image-f5fc8149-ba41-4425-9930-d3fe74dc94da](https://user-images.githubusercontent.com/36423985/134393511-d92fe8c0-b7f2-491b-970b-4f7a04add0b2.png)


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
![image](https://user-images.githubusercontent.com/36423985/134393566-f2a1c29f-e75f-4efd-8432-9021714711a3.png)
