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

    constructor() {
        super();
        GetPicklist().then(result => {
            this.statusOptions = result;
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
        });
    }
}