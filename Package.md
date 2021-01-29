# Salesforce to Google Sheets - Create Google Sheets spreadsheet rows from new Salesforce custom objects

## Integration Use Case 

This integration template listens to the created Salesforce Custom Objects and Insert them to a google sheet.

## Prerequisites

- [Ballerina Distribution](https://ballerina.io/learn/getting-started/)
- A Text Editor or an IDE ([VSCode](https://marketplace.visualstudio.com/items?itemName=ballerina.ballerina), 
[IntelliJ IDEA](https://plugins.jetbrains.com/plugin/9520-ballerina)).  
- [Salesforce Connector](https://github.com/ballerina-platform/module-ballerinax-sfdc) will be downloaded from 
[Ballerina Central](https://central.ballerina.io/) when running the Ballerina file.

#### Setup Salesforce Configurations
Create a Salesforce account and create a connected app by visiting [Salesforce](https://www.salesforce.com). 

Salesforce username, password and the security token that will be needed for initializing the listener. 

For more information on the secret token, please visit [Reset Your Security Token](https://help.salesforce.com/articleView?id=user_security_token.htm&type=5).

#### Create Custom Object in Salesforce
1. From the top-right corner of any page in Setup, click Create > Custom Object.
(If you cannot find, click settings icon and then click Service Setup. Then try step 1.)
2. Complete the fields for your custom object and configure its features.
3. If you want to create a custom tab for the object immediately after you save it, select Launch New Custom Tab Wizard after saving this custom object.
4. You can also create the custom object tab later in Setup by entering Tabs in the Quick Find box, and clicking Tabs.
5. Save the new object.
6. In the Object Manager, click Fields & Relationships, and create the custom fields that your object needs.

#### Create Push Topic in Salesforce developer console

The Salesforce trigger requires topics to be created for each event. We need to configure topic to listen on Custom Object entity.

1. From the Salesforce UI, select developer console. Go to debug > Open Execute Anonymous Window. 
2. Paste following apex code to create topic with <CustomObject> and execute.
e.g : Consider created custom object as 'Customer'. Check for 'Field Name' in the Fields of the custom object. Normally if the custom object is 'Customer', table that we need to listen will be like 'Customer__c' as following.
```apex
PushTopic pushTopic = new PushTopic();
pushTopic.Name = 'CustomerBroadcast';
pushTopic.Query = 'SELECT Id, Name, City, Country, Email, Phone FROM Customer__c';
pushTopic.ApiVersion = 48.0;
pushTopic.NotifyForOperationCreate = true;
pushTopic.NotifyForFields = 'Referenced';
insert pushTopic;
```
3. Once the creation is done, specify the topic name in the event listener service config.

#### Setup Google Sheets Configurations
Create a Google account and create a connected app by visiting [Google cloud platform APIs and Services](https://console.cloud.google.com/apis/dashboard). 

1. Click Library from the left side menu.
2. In the search bar enter Google Sheets.
3. Then select Google Sheets API and click Enable button.
4. Complete OAuth Consent Screen setup.
5. Click Credential tab from left side bar. In the displaying window click Create Credentials button
Select OAuth client Id.
6. Fill the required field. Add https://developers.google.com/oauthplayground to the Redirect URI field.
7. Get clientId and secret. Put it on the config(ballerina.conf) file.
8. Visit https://developers.google.com/oauthplayground/ 
    Go to settings (Top right corner) -> Tick 'Use your own OAuth credentials' and insert Oauth ClientId and secret.Click close.
9. Then,Complete Step1 (Select and Authotrize API's)
10. Make sure you select https://www.googleapis.com/auth/drive & https://www.googleapis.com/auth/spreadsheets Oauth scopes.
11. Click Authorize API's and You will be in Step 2.
12. Exchange Auth code for tokens.
13. Copy Access token and Refresh token. Put it on the config(ballerina.conf) file.


## Configuring the Integration Template

Create new spreadsheet. Type ``sheets.new`` in browser.
Rename the sheet if you want.
Copy the ID of the spreadsheet.
![alt text](https://github.com/SkNuwanTissera/ecs-template-sfdc-custom-to-gsheets/blob/master/blob/spreadsheetID.jpeg?raw=true)
and sheetname.
Once you obtained all configurations, Create `ballerina.conf` in root directory.
Replace "" in the `ballerina.conf` file with your data.

##### ballerina.conf

```

SF_USERNAME=""
SF_PASSWORD=""
SF_BROADCAST_TOPIC=""

DB_USER=""
DB_PWD=""

GS_ACCESS_TOKEN = ""
GS_CLIENT_ID = ""
GS_CLIENT_SECRET = ""
GS_REFRESH_TOKEN = ""
GS_REFRESH_URL = ""
GS_SPREADSHEET_ID = ""
GS_SHEET_NAME = ""

```


## Running the Template

1. First you need to build the integration template and create the executable binary. Run the following command from the root directory of the integration template. 
`$ ballerina build`. 

2. Then you can run the integration binary with the following command. 
`$ ballerina run /target/bin/<Name_of_Project>.jar`. 

Successful listener startup will print following in the console.
```
>>>>
[2020-09-25 11:10:55.552] Success:[/meta/handshake]
{ext={replay=true, payload.format=true}, minimumVersion=1.0, clientId=1mc1owacqlmod21gwe8arhpxaxxm, supportedConnectionTypes=[Ljava.lang.Object;@21a089fc, channel=/meta/handshake, id=1, version=1.0, successful=true}
<<<<
>>>>
[2020-09-25 11:10:55.629] Success:[/meta/connect]
{clientId=1mc1owacqlmod21gwe8arhpxaxxm, advice={reconnect=retry, interval=0, timeout=110000}, channel=/meta/connect, id=2, successful=true}
<<<<
```

3. Now you can add new records to created custom object in Salesforce Account and observe that integration template runtime has received the event notification for the broadcasted Salesforce Custom Object.

4.  You can check the Google Sheet to verify that the braodcasted Custom Objects are added to the Specied Sheet. 
