@istest
Private class PreventDeleteTest
{
    static testmethod void Testmeailmessage()
    {
        case cs = new case ();
            
                cs.subject = 'test';
                cs.priority = 'high';
            
        insert cs;
        test.startTest();
        EmailMessage em = new emailmessage();
            
               em.Subject = 'Hellow';
               em.FromAddress = 'mail.email@trovemoney.co.nz';
               em.ToAddress = 'email.address@mail.com';
        em.ParentId = cs.Id;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            
        insert em;
        try
        {
            delete em;
        }
        catch(DMLException e)
        {
         System.assert(e.getMessage().contains('You cannot delete This Email Message Please contact your System Administrator for assistance.'),'You cannot delete This Email Message Please contact your System Administrator for assistance.');   
        }
        Test.stopTest();
    }
}