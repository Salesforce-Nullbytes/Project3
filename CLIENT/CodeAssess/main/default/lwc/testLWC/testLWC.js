import { LightningElement, track } from 'lwc';
import GetPicklist from '@salesforce/apex/testLWCController.getStatusOptions';
import searchForRecords from '@salesforce/apex/testLWCController.searchForRecords';

export default class TestLWC extends LightningElement {
    searchTerm = '';
    passPercentage = '';
    resultStatusSelected = '';
    @track
    statusOptions;
    recordList;

    data = [];

    columns = [
        { label: 'Name', fieldName: 'name' },
        {
            label: 'Pass Percentage',
            fieldName: 'passpercent',
            type: 'number',
            cellAttributes: { alignment: 'left' },
        },
        { label: 'Start Time', fieldName: 'start', type: 'string' },
        { label: 'Submit Time', fieldName: 'submit', type: 'string' },
        { label: 'Status', fieldName: 'status', type: 'string' }
    ];

    constructor() {
        super();
        GetPicklist().then(result => {
            this.statusOptions = result;
        });
        searchForRecords({searchTerm: '', passPercentage: '', statusSelected: ''}).then(result => {
            this.recordList = result;

            result.forEach(item => {
                let returnArr = [];
                returnArr.push({id: item.Id, name: item.Contact__r.Name, passpercent: item.PassPercentage__c, start: item.StartTime__c, submit: item.SubmitTime__c, status: item.Status__c});
                this.data = returnArr;
            });
        });
    }

    handleNameInput(event) {
        this.searchTerm = event.detail.value;
    }

    handlePassPercentageInput(event) {
        this.passPercentage = event.detail.value;
    }

    handleStatusSelection(event) {
        this.resultStatusSelected = event.detail.value;
    }

    handleSearchClicked(event) {
        searchForRecords({searchTerm: this.searchTerm, passPercentage: this.passPercentage, statusSelected: this.resultStatusSelected}).then(result => {
            this.recordList = result;
            result.forEach(item => {
                let returnArr = [];
                returnArr.push({id: item.Id, name: item.Name, passpercent: item.PassPercentage__c, start: item.StartTime__c, submit: item.SubmitTime__c, status: item.Status__c});
                this.data = returnArr;
            });
        });
    }
}