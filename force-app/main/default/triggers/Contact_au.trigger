trigger Contact_au on Contact (after update)
{
    List<Contact> activatedContacts = new List<Contact>();
    for (Id conId : trigger.newMap.keySet())
    {
        Contact oldCon = trigger.oldMap.get(conId);
        Contact newCon = trigger.newMap.get(conId);

        if (!oldCon.Active__c && newCon.Active__c)
        {
            activatedContacts.add(newCon);
        }
    }

    if (!activatedContacts.isEmpty())
    {
        AccountWorker.HandleContactsActivated(activatedContacts);
    }
}