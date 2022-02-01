import { LightningElement, track } from 'lwc';
import fetchQuestionList from '@salesforce/apex/questionSetCreatorController.fetchQuestionList';
import insertQuestionSet from '@salesforce/apex/questionSetCreatorController.insertQuestionSet';
import checkDupe from '@salesforce/apex/questionSetCreatorController.checkDuplicate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class QuestionSetCreator extends LightningElement {
    @track
    questionTree = [];
    qTreeFilledBool = false;
    @track
    addedQuestionsList = [];
    qSetName = '';
    showLoading = false;

    constructor() {
        super();
        fetchQuestionList({searchTerm: ''}).then(result => {
            this.updateTree(result);
            this.qTreeFilledBool = true;
        });
    }

    handleOnSelect(event) {
        if (event.detail.name != 'INTERNAL_USE_topic') {
            let dupeFound = false;
            //duplicate detection
            this.addedQuestionsList.forEach(item => {
                if (item.name == event.detail.name) {
                    let event = new ShowToastEvent({
                        title: 'Duplicate',
                        message: 'That question is already selected!',
                        variant: 'warning'
                    });
                    this.dispatchEvent(event);
                    dupeFound = true;
                }
            });
            if (!dupeFound) {
                this.addedQuestionsList.push({
                    label: event.detail.name,
                    name: event.detail.name
                });
            }
        }
    }

    handlePillRemove(event) {
        let index = event.detail.index;
        this.addedQuestionsList.splice(index, 1);
    }

    handleSubmitClicked() {
        this.showLoading = true;

        let paramList = [];
        this.addedQuestionsList.forEach(item => {
            paramList.push(item.name);
        });

        checkDupe({qsName: this.qSetName}).then(result => {
            console.log(result);
            console.log(this.qSetName);
            let msg;
            if (result) {
                msg = 'A set with that name already exists!';
            } else if (paramList.length == 0) {
                msg = 'You need at least one question selected to make a question set!'
            } else if (this.qSetName == '' || this.qSetName == undefined || this.qSetName == null) {
                msg = 'Question set name is required!';
            }

            if (msg) {
                let event = new ShowToastEvent({
                    title: 'Error',
                    message: msg,
                    variant: 'error'
                });
                this.dispatchEvent(event);
                this.showLoading = false;
                return;
            }

            insertQuestionSet({sName: this.qSetName, nameList: paramList}).then( result => {
                if (result) {
                    let event = new ShowToastEvent({
                        title: 'Success',
                        message: 'Question set added!',
                        variant: 'success'
                    });
                    this.dispatchEvent(event);
                    this.qSetName = '';
                    this.addedQuestionsList = [];
                    this.template.querySelector('.searchInput').value = '';
                    fetchQuestionList({searchTerm: ''}).then(result => {
                        this.updateTree(result);
                        this.showLoading = false;
                    });
                } else {
                    this.showLoading = false;
                }
            });
        });
    }

    handleNameInput(event) {
        this.qSetName = event.detail.value;
    }

    handleSearchInput(event) {
        if (event.keyCode === 13) {
            this.showLoading = true;
            fetchQuestionList({searchTerm: this.template.querySelector('.searchInput').value}).then(result => {
                this.updateTree(result);
                this.showLoading = false;
            });
        }
    }

    updateTree(result) {
        let topicMap = {};

        result.forEach(item => {
            if (topicMap[item.QuestionTopic__c] == null) {
                topicMap[item.QuestionTopic__c] = [];
            }
            let buildingMetaText = item.Prompt__c.substring(0, 75);
            if (item.Prompt__c.length > 75) {
                buildingMetaText += '...';
            }
            topicMap[item.QuestionTopic__c].push({
                label: item.Name,
                name: item.Name,
                disabled: false,
                expanded: false,
                metatext: buildingMetaText
            });
        });

        Object.getOwnPropertyNames(topicMap).forEach(item => {
            this.questionTree.push({
                label: item,
                name: 'INTERNAL_USE_topic',
                disabled: false,
                expanded: false,
                items: topicMap[item]
            });
        });
        
    }
}