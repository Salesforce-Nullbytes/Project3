import { LightningElement, track } from 'lwc';
import fetchQuestionList from '@salesforce/apex/questionSetCreatorController.fetchQuestionList';
import insertQuestionSet from '@salesforce/apex/questionSetCreatorController.insertQuestionSet';

export default class QuestionSetCreator extends LightningElement {
    questionTree = [];
    qTreeFilledBool = false;
    @track
    addedQuestionsList = [];
    qSetName;

    constructor() {
        super();
        fetchQuestionList().then(result => {
            let topicMap = {};

            result.forEach(item => {
                if (topicMap[item.QuestionTopic__c] == null) {
                    topicMap[item.QuestionTopic__c] = [];
                }
                topicMap[item.QuestionTopic__c].push({
                    label: item.Name,
                    name: item.Name,
                    disabled: false,
                    expanded: false,
                    metatext: item.Prompt__c.substring(0, 25)
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
            this.qTreeFilledBool = true;
        });
    }

    handleOnSelect(event) {
        if (event.detail.name != 'INTERNAL_USE_topic') {
            this.addedQuestionsList.push({
                label: event.detail.name,
                name: event.detail.name
            });
        }
    }

    handlePillRemove(event) {
        let index = event.detail.index;
        this.addedQuestionsList.splice(index, 1);
    }

    handleSubmitClicked() {
        let paramList = [];
        this.addedQuestionsList.forEach(item => {
            paramList.push(item.name);
        });
        insertQuestionSet({sName: this.qSetName, nameList: paramList}).then( result => {
            if (result) {
                //TODO IMPLEMENT
                console.log('reached');
            } else {

            }
        });
    }

    handleNameInput(event) {
        this.qSetName = event.detail.value;
    }
}