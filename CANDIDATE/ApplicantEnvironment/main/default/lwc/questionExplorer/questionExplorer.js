import { LightningElement, wire } from 'lwc';
import getQuestionSet from '@salesforce/apex/RESTcallout.getQuestionSet';

export default class QuestionExplorer extends LightningElement {
    @wire(getQuestionSet,{url: ''}) quesitonSet;
}
