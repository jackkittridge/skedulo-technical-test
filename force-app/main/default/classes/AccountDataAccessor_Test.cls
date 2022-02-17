@isTest
private with sharing class AccountDataAccessor_Test
{
    private static final Integer NUM_ACCOUNT_RECORDS = 50;
    @isTest
    private static void Test_GetAccounts() 
    {
        List<Account> accounts = [SELECT Id, Name FROM Account];
        System.assertEquals(NUM_ACCOUNT_RECORDS, accounts.size());

    }

    @TestSetup
    private static void makeData()
    {
        List<Account> accountsToInsert = new List<Account>();
        for (Integer i = 0; i < NUM_ACCOUNT_RECORDS; i++)
        {
            accountsToInsert.add(new Account(
                Name = 'TestAccount ' + i
            ));

        }

        insert accountsToInsert;
    }
}
