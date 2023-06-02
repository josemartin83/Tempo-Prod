trigger PreventDelete on EmailMessage (before delete)
{ 
      if(System.Trigger.IsDelete)
       { 
            Id profileId = userinfo.getProfileId();
            String profileName = [Select Id, Name from Profile where Id=:profileId].Name;
            for (EmailMessage em : trigger.old)
              {
                    if (String.isNotBlank(em.ParentId) && em.Status != '5' && profileName != 'System Administrator')
                      { 
                          System.debug('Status:' + em.Status);
                          System.debug('Profile Name: ' + profileName );
                          em.addError('You cannot delete This Email Message Please contact your System Administrator for assistance.');
                      } 
             } 
       }
}