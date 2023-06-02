public class AWSCallout
{ 
    public static String callAwsgateway(String customerId, String transactionId, Boolean Locked, Boolean Cloudcheckpass, Boolean PassedAML, Boolean pdsReceived)
    {
        //request body JSON
        JSONGenerator gen = JSON.createGenerator(true);    
        gen.writeStartObject();
        if (pdsReceived){
            gen.writeBooleanField('PDS_Received__c',pdsReceived);
            gen.writeStringField('Customer_ID__c', customerId);
        }
        else if(Locked == false && Locked!=null && PassedAML == False)
        {
            gen.writeBooleanField('Locked__c',Locked);
            gen.writeStringField('Customer_ID__c', customerId);
        }
         else if(PassedAML == True )
        {
            gen.writeBooleanField('Passed_AML__c',PassedAML);
            gen.writeStringField('Transaction_Id__c',transactionId);
            gen.writeStringField('Customer_ID__c', customerId);
        }
        
               
        //set JSON
        String jsonS = gen.getAsString();
        system.debug(jsonS);
        
        return jsonS;
    }  
    
    public static void personDetailsChangeCallout(List<Person_Detail_Change__e> listOfPersonDetailEvents){
        //Map of integration log data
        Map<String, String> integrationLogData = new Map<String, String>();
        //loop through event and generate JSON
        for(Person_Detail_Change__e thisEvent : listOfPersonDetailEvents){
            
            String jsonS = createJSON(thisEvent);
            
            //add the Id to integration log
            integrationLogData.put(jsonS, 'Person Details');            
        }
        
        if(integrationLogData.size() > 0){
            List<Id> integrationLogIds = initiateIntegrationLog(integrationLogData);
            //send the request - Queueable JOB
            System.enqueueJob(new AWSCalloutQueueable(integrationLogIds));
        }
    }

   
    
    public static List<Id> initiateIntegrationLog(Map<String, String> mapOfIntegrationsToInsert){
        List<Integration_Log__c> toInsertLogs = new List<Integration_Log__c>();
        List<Id> integrationLogIds = new List<Id>();
        for(String thisJSON : mapOfIntegrationsToInsert.keySet()){
            //Initialize an Integration Log record
            Integration_Log__c thisIntegrationLog = new Integration_Log__c();
            thisIntegrationLog.Request_JSON__c = thisJSON;
            thisIntegrationLog.Type__c = mapOfIntegrationsToInsert.get(thisJSON);
            toInsertLogs.add(thisIntegrationLog);   
        }
        //insert logs
        if(toInsertLogs.size() > 0){
            List<Database.SaveResult> srList = Database.insert(toInsertLogs);
            for(Database.SaveResult sr : srList){
                if(sr.isSuccess()){
                    integrationLogIds.add(sr.getId());
                }
            }
        }
        return integrationLogIds;
    }

    // Create JSON from Person Details Event 
    public static String createJSON(Person_Detail_Change__e thisEvent){
        //request body JSON
        JSONGenerator gen = JSON.createGenerator(true);    
        gen.writeStartObject();
        if(String.isNotEmpty(thisEvent.Customer_ID__c)){
            gen.writeStringField('Customer_ID__c', thisEvent.Customer_ID__c);
        }
        if(String.isNotEmpty(thisEvent.Type__c)){
            gen.writeStringField('Type__c', thisEvent.Type__c);
        }
        if(String.isNotEmpty(thisEvent.Mobile_Number__c)){
            gen.writeStringField('Mobile_Number__c', thisEvent.Mobile_Number__c);
        }
        if(String.isNotEmpty(thisEvent.PIR__c)){
            gen.writeStringField('PIR__c', thisEvent.PIR__c);
        }
        if(String.isNotEmpty(thisEvent.IRD_Number__c)){
            gen.writeStringField('IRD_Number__c', thisEvent.IRD_Number__c);
        }
        if(String.isNotEmpty(thisEvent.Street__c)){
            gen.writeStringField('Street__c', thisEvent.Street__c);
        }
        if(String.isNotEmpty(thisEvent.Suburb__c)){
            gen.writeStringField('Suburb__c', thisEvent.Suburb__c);
        }
        if(String.isNotEmpty(thisEvent.City__c)){
            gen.writeStringField('City__c', thisEvent.City__c);
        }
        if(String.isNotEmpty(thisEvent.Country__c)){
            gen.writeStringField('Country__c', thisEvent.Country__c);
        }
        if(thisEvent.Postal_Code__c != null){
            gen.writeNumberField('Postal_Code__c', Integer.valueOf(thisEvent.Postal_Code__c));
        }
        if(String.isNotEmpty(thisEvent.First_Name__c)){
            gen.writeStringField('First_Name__c', thisEvent.First_Name__c);
        }
        if(String.isNotEmpty(thisEvent.Last_Name__c)){
            gen.writeStringField('Last_Name__c', thisEvent.Last_Name__c);
        }
         if(String.isNotEmpty(thisEvent.Bank_Name__c)){
            gen.writeStringField('Bank_Name__c', thisEvent.Bank_Name__c);
        }
         if(String.isNotEmpty(thisEvent.Bank_Number__c)){
            gen.writeStringField('Bank_Number__c', thisEvent.Bank_Number__c);
        }
        if(String.isNotEmpty(thisEvent.Account_Nickname__c)){
            gen.writeStringField('Account_Nickname__c', thisEvent.Account_Nickname__c);
        }
        if(String.isNotEmpty(thisEvent.Bank_Status__c)){
            gen.writeStringField('Bank_Status__c', thisEvent.Bank_Status__c);
        }  
        if(String.isNotEmpty(thisEvent.Close_Request__c)){
            gen.writeStringField('Close_Request__c', thisEvent.Close_Request__c);
        }   
        if(String.isNotEmpty(thisEvent.ID_Type__c)){
            gen.writeStringField('ID_Type__c', thisEvent.ID_Type__c);
        } 
        if(String.isNotEmpty(thisEvent.ID_Number__c)){
            gen.writeStringField('ID_Number__c', thisEvent.ID_Number__c);
        } 
        if(String.isNotEmpty(String.valueOf(thisEvent.ID_Expiry_Date__c))){
            gen.writeStringField('ID_Expiry_Date__c', String.valueOf(thisEvent.ID_Expiry_Date__c));
        } 
        if(String.isNotEmpty(thisEvent.ID_Version__c)){
            gen.writeStringField('ID_Version__c', thisEvent.ID_Version__c);
        }  
        if(String.isNotEmpty(String.valueOf(thisEvent.Birthdate__c))){
            gen.writeStringField('Birthdate__c', String.valueOf(thisEvent.Birthdate__c));
        }
        if(String.isNotEmpty(thisEvent.ID_First_Name__c)){
            gen.writeStringField('ID_First_Name__c', thisEvent.ID_First_Name__c);
        }
        if(String.isNotEmpty(thisEvent.ID_Middle_Name__c)){
            gen.writeStringField('ID_Middle_Name__c', thisEvent.ID_Middle_Name__c);
        }
        if(String.isNotEmpty(thisEvent.ID_Last_Name__c)){
            gen.writeStringField('ID_Last_Name__c', thisEvent.ID_Last_Name__c);
        }
        if(String.isNotEmpty(thisEvent.Pause_Trading__c)){
            gen.writeStringField('Pause_Trading__c', thisEvent.Pause_Trading__c);
        }
        if(String.isNotEmpty(thisEvent.Timestamp__c)){
            gen.writeStringField('Timestamp__c', thisEvent.Timestamp__c);
        }
        //set JSON
        String jsonS = gen.getAsString();
        system.debug(jsonS);

        return jsonS;
    }
     

}