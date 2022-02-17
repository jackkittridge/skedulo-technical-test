trigger Contact_ad on Contact (after delete)
{
    AccountWorker.HandleContactsDeleted(trigger.old);
}