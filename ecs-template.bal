import ballerina/io;
import ballerina/config;
import ballerina/log;
import ballerinax/sfdc;
import ballerinax/googleapis_sheets as sheets;

const string TYPE_CREATED = "created";

sheets:SpreadsheetConfiguration spreadsheetConfig = {
    oauth2Config: {
        accessToken: config:getAsString("GS_ACCESS_TOKEN"),
        refreshConfig: {
            clientId: config:getAsString("GS_CLIENT_ID"),
            clientSecret: config:getAsString("GS_CLIENT_SECRET"),
            refreshUrl: sheets:REFRESH_URL,
            refreshToken: config:getAsString("GS_REFRESH_TOKEN")
        }
    }
};

sfdc:ListenerConfiguration listenerConfig = {
    username: config:getAsString("SF_USERNAME"),
    password: config:getAsString("SF_PASSWORD")
};

listener sfdc:Listener sfdcEventListener = new (listenerConfig);
sheets:Client spreadsheetClient = new (spreadsheetConfig);


@sfdc:ServiceConfig {
    topic: TOPIC_PREFIX + config:getAsString("SF_BROADCAST_TOPIC")
}
service on sfdcEventListener {
    remote function onEvent(json op) {
        io:StringReader sr = new(op.toJsonString());
        json|error customObj = sr.readJson();
        if ((customObj is json) && (TYPE_CREATED.equalsIgnoreCaseAscii(customObj.event.'type.toString()))){
            var result = addObjectToSpreadsheet(customObj);
            // var result2 = addObjectToSpreadsheet2(customObj);
            if (result is error) {
                log:printError(result.message());
            }
        }
    }
}

function addObjectToSpreadsheet(json customObject) returns @tainted error?{
    io:print("JSON :" ,customObject);
    (string|int)[] values = [];

    map<json> mapValue = <map<json>>customObject.sobject;
    foreach var value in mapValue {
        if (value is string) {
            values.push(value);
            io:println("string value: ", value);
        } else {
            values.push(value.toString());
            io:println("non-string value: ", value);
        }
    }

    sheets:Spreadsheet spreadsheet = check spreadsheetClient->openSpreadsheetById(config:getAsString("GS_SPREADSHEET_ID"));
    sheets:Sheet sheet = check spreadsheet.getSheetByName(config:getAsString("GS_SHEET_NAME"));
    error? appendResult = sheet->appendRow(values);
    log:print("New row in spreadsheet : " + values.toString());           
}

