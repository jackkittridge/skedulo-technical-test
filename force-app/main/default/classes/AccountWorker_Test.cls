@isTest
private class AccountWorker_Test
{
    private static final Integer NUM_ACCOUNT_RECORDS = 10;
    private static final Integer NUM_CONTACTS_PER_ACCOUNT = 5;

    @isTest
    private static void HandleContactsActivated_SingleTest() 
    {
        Account acc = [SELECT Id, NumberOfContacts__c FROM Account LIMIT 1];
        System.assertEquals(0, acc.NumberOfContacts__c); // Currently not activated

        Contact con = [SELECT Id, Active__c FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        con.Active__c = true;

        Test.startTest();
            update con;
        Test.stopTest();

        acc = [SELECT Id, NumberOfContacts__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(1, acc.NumberOfContacts__c);
    }

    @isTest
    private static void HandleContactsActivated_BulkTest()
    {
        List<Account> accounts = [SELECT Id, NumberOfContacts__c FROM Account];
        for (Account acc : accounts)
        {
            System.assertEquals(0, acc.NumberOfContacts__c);
        }

        List<Contact> contacts = [SELECT Id, Active__c FROM Contact];
        for (Contact con : contacts) 
        {
            con.Active__c = true;
        }

        Test.startTest();
            update contacts;
        Test.stopTest();

        accounts = [SELECT Id, NumberOfContacts__c FROM Account];
        for (Account acc : accounts)
        {
            System.assertEquals(NUM_CONTACTS_PER_ACCOUNT, acc.NumberOfContacts__c);
        }
    }

    @isTest
    private static void HandleContactsDeleted_SingleTest() 
    {
        List<Contact> contacts = [SELECT Id, Active__c FROM Contact];
        for (Contact con : contacts) 
        {
            con.Active__c = true;
        }
        update contacts; // Activating all the contacts first

        Account acc = [SELECT Id, NumberOfContacts__c FROM Account LIMIT 1];
        Contact existingCon = [SELECT Id, Active__c FROM Contact WHERE AccountId = :acc.Id LIMIT 1];

        Test.startTest();
            delete existingCon;
        Test.stopTest();

        acc = [SELECT Id, NumberOfContacts__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(NUM_CONTACTS_PER_ACCOUNT-1, acc.NumberOfContacts__c);
    }

    @isTest
    private static void HandleContactsDeleted_BulkTest()
    {
        List<Contact> contacts = [SELECT Id, AccountId, Active__c FROM Contact];
        for (Contact con : contacts) 
        {
            con.Active__c = true;
        }
        update contacts; // Activating all the contacts first

        List<Account> accs = [SELECT Id, NumberOfContacts__c FROM Account];
        Map<Id, Contact> contactByAccount = new Map<Id, Contact>();
        for (Contact con : contacts) 
        {
            // Realistically since we're only deleting 1 we can overwrite the contact here, doesn't really matter
            contactByAccount.put(con.AccountId, con);
        }

        Test.startTest();
            delete contactByAccount.values();
        Test.stopTest();

        accs = [SELECT Id, NumberOfContacts__c FROM Account];
        for (Account acc : accs)
        {
            System.assertEquals(NUM_CONTACTS_PER_ACCOUNT-1, acc.NumberOfContacts__c);
        }
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

        List<Contact> contactsToInsert = new List<Contact>();
        for (Account acc : accountsToInsert) 
        {
            for (Integer i = 0; i < NUM_CONTACTS_PER_ACCOUNT; i++)
            {
                contactsToInsert.add(new Contact(
                    AccountId = acc.Id,
                    LastName = 'Testleton ' + i
                ));
            }
        }

        insert contactsToInsert;
    }
}
