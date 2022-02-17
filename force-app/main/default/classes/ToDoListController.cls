public with sharing class ToDoListController
{
    @AuraEnabled(cacheable=true)
    public static List<To_Do__c> GetToDoItems()
    {
        return [
            SELECT Id, Name, Contact__r.Name, Actions__c, Status__c
            FROM To_Do__c
            WHERE CreatedById = :UserInfo.getUserId()
            ORDER BY CreatedDate DESC
        ];
    }
}
