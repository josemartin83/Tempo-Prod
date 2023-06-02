trigger SetFileVisibilityForCases on ContentDocumentLink (before insert) {
    Schema.DescribeSObjectResult r = Case.sObjectType.getDescribe();
    String keyPrefix = r.getKeyPrefix();

      for(ContentDocumentLink cdl:trigger.new){
        if((String.valueOf(cdl.LinkedEntityId)).startsWith(keyPrefix)){
          cdl.ShareType = 'I';
          cdl.Visibility = 'AllUsers';
          } 
       }
}