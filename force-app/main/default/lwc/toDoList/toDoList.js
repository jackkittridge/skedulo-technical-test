import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

import GetToDoItems from '@salesforce/apex/ToDoListController.GetToDoItems';

import TODO_OBJECT_NAME from '@salesforce/schema/To_Do__c';
import TODO_NAME_FIELD from '@salesforce/schema/To_Do__c.Name';
import TODO_CONTACT_FIELD from '@salesforce/schema/To_Do__c.Contact__c';
import TODO_ACTIONS_FIELD from '@salesforce/schema/To_Do__c.Actions__c';
import TODO_STATUS_FIELD from '@salesforce/schema/To_Do__c.Status__c';

const actions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },
];

const columns = [
    { label: 'Name', fieldName: 'todoUrl', type: 'url', typeAttributes: { label: { fieldName: 'Name' }}},
    { label: 'Contact', fieldName: 'contactUrl', type: 'url', typeAttributes: {label: { fieldName: 'contactName'}}},
    { label: 'Actions', fieldName: 'Actions__c', type: 'string' },
    { label: 'Status', fieldName: 'Status__c', type: 'string' },
    { type: 'action', typeAttributes: { rowActions: actions } }
];


export default class ToDoList extends LightningElement 
{
    toDoApiName = TODO_OBJECT_NAME;
    toDoFields = [TODO_NAME_FIELD, TODO_CONTACT_FIELD, TODO_ACTIONS_FIELD, TODO_STATUS_FIELD];

    columns = columns;

    editRecordId = null;

    showModal = false;
    
    toDos;
    wireResult;
    @wire(GetToDoItems)
    gotToDoItems(result)
    {
        this.wireResult = result;
        if (result.data)
        {
            this.toDos = result.data.map((item) => ({
                ...item,
                todoUrl: '/lightning/r/To_Do__c/' +item['Id'] +'/view',
                contactName: item['Contact__r']['Name'],
                contactUrl: '/lightning/r/Contact/' + item['Contact__c'] + '/view'
            }));
        }
    }

    get haveToDos()
    {
        return null != this.toDos && this.toDos.length > 0;
    }

    handleRowAction(event)
    {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'edit':
                this.editRecordId = row.Id;
                this.showModal = true;
                break;
            case 'delete':
                deleteRecord(row.Id)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record deleted successfully',
                            variant: 'success'
                        })
                    );
                    refreshApex(this.wireResult);
                })
                break;
        }

    }
    
    handleNewToDoClicked() 
    {
        this.editRecordId = null;
        this.showModal = true;
    }

    handleToDoSaved() 
    {
        this.editRecordId = null;
        this.closeModal();

        if (null == this.editRecordId) 
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'To-Do Created!',
                message: 'Successfully created a new To-Do',
                variant: 'success'
            }));
        }
        else
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'To-Do Edited!',
                message: 'Successfully updated To-Do',
                variant: 'success'
            }));
        }

        if (null != this.wireResult)
        {
            refreshApex(this.wireResult);
        }
    }

    get hasEditId() 
    {
        return null != this.editRecordId || undefined != this.editRecordId;
    }

    get modalTitle()
    {
        return this.hasEditId ? 'Edit To-Do' : 'Create To-Do';
    }

    closeModal() 
    {
        this.showModal = false;
    }
}