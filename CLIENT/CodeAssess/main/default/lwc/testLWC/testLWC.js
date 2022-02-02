import { LightningElement, wire, track } from 'lwc';
import GetPicklist from '@salesforce/apex/testLWCController.getStatusOptions';
import searchForRecords from '@salesforce/apex/testLWCController.searchForRecords';

const COLS=[  
    //{label:'LastName',fieldName:'LastName', type:'string'},  
    {label:'Contact',fieldName:'name', type:'text'},  
    {label:'PassPercentage',fieldName:'passPercent', type:'number'},
    {label:'Status',fieldName:'status', type:'text'}  
  ];

  
export default class TestLWC extends LightningElement {
    searchTerm = '';
    passPercentage = '';
    resultStatusSelected = '';
  
    value = 'All';

    get statusOptions() {
        return [
            { label: 'Active', value: 'active' },
            { label: 'Completed', value: 'completed' },
            { label: 'Abandoned', value: 'abandoned' },
            { label: 'All', value: '' },
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
    }

    cols=COLS;  
   @wire(searchForRecords) sssList; 
 
    //@track
    //statusOptions;
    recordList;
    @track
    data;
    constructor() {
        super();
        GetPicklist().then(result => {
        //    this.statusOptions = result;
        });
        searchForRecords({searchTerm:'', passPercentage:'', statusSelected:''}).then(result=>{
            this.recordList = result;
            let returnArray = [];
            console.log(result);
            result.forEach(item=>{
                let dataItem = {
                    name:null, 
                    passPercent:null,
                    status:null,
                    id:null
                }
                if (item.Contact__r){
                    dataItem.name=item.Contact__r.Name
                }
                if (item.PassPercentage__c){
                    dataItem.passPercent=item.PassPercentage__c
                }
                if (item.Status__c){
                    dataItem.status=item.Status__c
                }
                returnArray.push(dataItem);
               
           });
           //returnArray
           this.data = returnArray;
           console.log(returnArray);
        });
    }

    handleNameInput(event) {
      this.searchTerm = event.target.value;
    }

    handlePassPercentageInput(event) {
        this.passPercentage = event.target.value;
    }

    handleStatusSelection(event) {
        this.resultStatusSelected = event.target.value;
    }

    handleSearchClicked(event) {
        searchForRecords({searchTerm: this.searchTerm, passPercentage: this.passPercentage, statusSelected: this.resultStatusSelected}).then(result => {
            this.recordList = result;
            let returnArray = [];
            console.log(result);
            result.forEach(item=>{
                let dataItem = {
                    name:null, 
                    passPercent:null,
                    status:null,
                    id:null
                }
                if (item.Contact__r){
                    dataItem.name=item.Contact__r.Name
                }
                if (item.PassPercentage__c){
                    dataItem.passPercent=item.PassPercentage__c
                }
                if (item.Status__c){
                    dataItem.status=item.Status__c
                }
                returnArray.push(dataItem);
               
           });
           //returnArray
           this.data = returnArray;
           console.log(returnArray);
        });
    }
}