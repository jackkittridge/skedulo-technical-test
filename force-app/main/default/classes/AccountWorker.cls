public with sharing class AccountWorker
{
    // Alternatively I could named this something like HandleContactDMLs(List<Contact> contacts, Boolean isDelete)
    // Where the 2nd parameter came from a shared trigger using the available trigger context variables (Trigger.isDelete)
    // In this scenario, we'd only have the one method [...]
    // [...] and the 2nd isDelete parameter would determine whether we increment or decrement NumberOfContacts
    public static void HandleContactsActivated(List<Contact> contacts)
    {
        Map<Id, Account> accountById = GetAccountsById(contacts);
        for (Contact con : contacts) 
        {
            Account acc = accountById.get(con.AccountId);
            if (null != acc)
            {
                acc.NumberOfContacts__c += 1;
            }
        }

        try 
        {
            update accountById.values();
        }
        catch (DmlException dml_exc)
        {
            // Would do something more meaningful than a system debug in reality
            System.debug('Failed to update accounts');
        }       
    }

    public static void HandleContactsDeleted(List<Contact> contacts)
    {
        Map<Id, Account> accountById = GetAccountsById(contacts);
        for (Contact con : contacts) 
        {
            Account acc = accountById.get(con.AccountId);
            if (null != acc)
            {
                acc.NumberOfContacts__c -= 1;
            }
        }

        try 
        {
            update accountById.values();
        }
        catch (DmlException dml_exc)
        {
            // Again, would probably do something more valuable here.
            System.debug('Failed to update accounts');
        }  
    }

    private static Map<Id, Account> GetAccountsById(List<Contact> contacts)
    {
        Set<Id> accountIds = new Set<Id>();
        for (Contact con : contacts) 
        {
            accountIds.add(con.AccountId);
        }

        return AccountDataAccessor.GetAccounts(accountIds);
    }
}
