public with sharing class AccountDataAccessor
{
    public static Map<Id, Account> GetAccounts(Set<Id> accountIds)
    {
        return new Map<Id, Account>([
            SELECT Id, Name, NumberOfContacts__c
            FROM Account
            WHERE Id IN :accountIds
        ]);
    }
}
