public class PersonAccountTriggerHandler {
    
    public static void personAccountDetailsChanged(List<Account> accountList, Map<Id, Account> oldAccountMap){
        List<Account> changedAccounts = new List<Account>();
        for(Account thisAccount : accountList){
                Account oldAccountValues = oldAccountMap.get(thisAccount.Id);
                System.debug('oldAccountMap ' + oldAccountMap);
                if(oldAccountValues.PersonMobilePhone != thisAccount.PersonMobilePhone ||
                   oldAccountValues.PIR__c != thisAccount.PIR__c ||
                   oldAccountValues.IRD_Number__c != thisAccount.IRD_Number__c ||
                   //Name fields
                   oldAccountValues.FirstName != thisAccount.FirstName ||
                   oldAccountValues.LastName != thisAccount.LastName ||
                   oldAccountValues.PersonBirthdate != thisAccount.PersonBirthdate ||
                   //Address fields
                   oldAccountValues.Mailing_Street__c != thisAccount.Mailing_Street__c ||
                   oldAccountValues.Mailing_City__c != thisAccount.Mailing_City__c ||   
                   oldAccountValues.Mailing_Suburb__c != thisAccount.Mailing_Suburb__c ||
                   oldAccountValues.Mailing_Country__c != thisAccount.Mailing_Country__c ||
                   oldAccountValues.Mailing_Post_Zip__c != thisAccount.Mailing_Post_Zip__c ||
                   // ID fields
                   oldAccountValues.ID_First_Name__c != thisAccount.ID_First_Name__c ||
                   oldAccountValues.ID_Middle_Name__c != thisAccount.ID_Middle_Name__c ||
                   oldAccountValues.ID_Last_Name__c != thisAccount.ID_Last_Name__c ||
                   oldAccountValues.ID_Type__c != thisAccount.ID_Type__c ||
                   oldAccountValues.ID_Number__c != thisAccount.ID_Number__c ||
                   oldAccountValues.ID_Expiry_Date__c != thisAccount.ID_Expiry_Date__c ||
                   oldAccountValues.ID_Version__c != thisAccount.ID_Version__c
                   )
                   {
                       System.debug('Changed Account added');
                       changedAccounts.add(thisAccount);
                   }    
        }
        //check the changed accounts size
        if(changedAccounts.size() > 0){
            List<Person_Detail_Change__e> personDetailsChangedPlatformEvent = generatePlatformEvent(changedAccounts, oldAccountMap);
            EventBus.publish(personDetailsChangedPlatformEvent);
        }
    }

    public static List<Person_Detail_Change__e> generatePlatformEvent(List<Account> listOfChangedAccounts, Map<Id, Account> oldAccountMap){
        List<Person_Detail_Change__e> platformEventsToReturn = new List<Person_Detail_Change__e>();
        
        for(Account thisAccount : listOfChangedAccounts){
            //old Account
            Account oldAccountValues = oldAccountMap.get(thisAccount.Id);
            
            // Add Id fields if any id fields have been changed and create a new platformm event            
            if(
                // check name and birthdate fields
                oldAccountValues.ID_First_Name__c != thisAccount.ID_First_Name__c ||
                oldAccountValues.ID_Middle_Name__c != thisAccount.ID_Middle_Name__c ||
                oldAccountValues.ID_Last_Name__c != thisAccount.ID_Last_Name__c ||
                oldAccountValues.PersonBirthdate != thisAccount.PersonBirthdate ||

                // check address fields
                oldAccountValues.Mailing_Street__c != thisAccount.Mailing_Street__c ||
                oldAccountValues.Mailing_City__c != thisAccount.Mailing_City__c ||
                oldAccountValues.Mailing_Suburb__c != thisAccount.Mailing_Suburb__c ||
                oldAccountValues.Mailing_Country__c != thisAccount.Mailing_Country__c ||
                oldAccountValues.Mailing_Post_Zip__c != thisAccount.Mailing_Post_Zip__c ||

                // check id fields
                oldAccountValues.ID_Type__c != thisAccount.ID_Type__c ||
                oldAccountValues.ID_Number__c != thisAccount.ID_Number__c ||
                oldAccountValues.ID_Expiry_Date__c != thisAccount.ID_Expiry_Date__c ||
                oldAccountValues.ID_Version__c != thisAccount.ID_Version__c
            ){
                Person_Detail_Change__e event = new Person_Detail_Change__e();
                //set customer ID
                event.Customer_ID__c = thisAccount.Customer_ID__c;
                event = populatePlatformEventWithIdFields(event, thisAccount);
                platformEventsToReturn.add(event);

            }

            // Add other fields and create a new platform event
            if (oldAccountValues.PersonMobilePhone!= thisAccount.PersonMobilePhone ||
                oldAccountValues.PIR__c != thisAccount.PIR__c ||
                oldAccountValues.IRD_Number__c != thisAccount.IRD_Number__c ||
                oldAccountValues.FirstName!= thisAccount.FirstName ||
                oldAccountValues.LastName!= thisAccount.LastName) {

                Person_Detail_Change__e thisPersonDetailEvent = new Person_Detail_Change__e();
                //set customer ID
                thisPersonDetailEvent.Customer_ID__c = thisAccount.Customer_ID__c;
                //check phone field
                if(oldAccountValues.FirstName!= thisAccount.FirstName){
                    thisPersonDetailEvent.First_Name__c = String.valueOf(thisAccount.FirstName);    
                }
                //check phone field
                if(oldAccountValues.LastName!= thisAccount.LastName){
                    thisPersonDetailEvent.Last_Name__c = String.valueOf(thisAccount.LastName);    
                }
                //check phone field
                if(oldAccountValues.PersonMobilePhone!= thisAccount.PersonMobilePhone){
                    thisPersonDetailEvent.Mobile_Number__c = String.valueOf(thisAccount.PersonMobilePhone);    
                }
                //check PIR field
                if(oldAccountValues.PIR__c != thisAccount.PIR__c){
                    thisPersonDetailEvent.PIR__c = String.valueOf(thisAccount.PIR__c);    
                }
                //check IRD Number field
                if(oldAccountValues.IRD_Number__c != thisAccount.IRD_Number__c){
                    thisPersonDetailEvent.IRD_Number__c = String.valueOf(thisAccount.IRD_Number__c);    
                }
                platformEventsToReturn.add(thisPersonDetailEvent);

            }
        }
        //return list of platform events to insert
        return platformEventsToReturn;
    }

    /*********************************************************************************************************
     * @name			populatePlatformEventWithIdFields
     * @author			Sze-Meeng Tan <sze=meeng@beintelligent.nz>
     * @created			14 / 06 / 2022
     * @description		Populate the person detail event platform even with all the id fields
     * @param			Person_Detail_Change__e event : The platform event with the populated values
     **********************************************************************************************************/
    private static Person_Detail_Change__e populatePlatformEventWithIdFields(Person_Detail_Change__e event, Account acc){
        // Add Name fields
        event.ID_First_Name__c = acc.ID_First_Name__c;    
        event.ID_Middle_Name__c = acc.ID_Middle_Name__c;    
        event.ID_Last_Name__c = acc.ID_Last_Name__c;   
        
        //Add Address fields
        event.Street__c = acc.Mailing_Street__c;    
        event.City__c = acc.Mailing_City__c;    
        event.Suburb__c = acc.Mailing_Suburb__c;    
        event.Country__c = acc.Mailing_Country__c;    
        event.Postal_Code__c = acc.Mailing_Post_Zip__c != null ? Integer.valueOf(acc.Mailing_Post_Zip__c) : null; 
        
        // Add Birthdate
        event.Birthdate__c = acc.PersonBirthdate;    

        // Add Id Fields
        event.ID_Type__c = acc.ID_Type__c; 
        event.ID_Number__c = acc.ID_Number__c; 
        event.Type__c = 'Id_Details'; 
        System.debug('acc.ID_Type__c====> ' + acc.ID_Type__c);
        switch on acc.ID_Type__c {
            when 'Passport' {
                event.ID_Expiry_Date__c = acc.ID_Expiry_Date__c; 
            }
            when 'Driver Licence' {
                event.ID_Version__c = acc.ID_Version__c; 
            } when else {
                System.debug('in the whenelse');
            }
        }

        System.debug('person detail change event population ' + event);
        return event;
    }
}