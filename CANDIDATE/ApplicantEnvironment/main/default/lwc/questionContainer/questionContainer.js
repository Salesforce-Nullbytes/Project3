import { LightningElement, api } from 'lwc';

export default class QuestionContainer extends LightningElement {

    @api
    question;

    @api
    submission;

    tabContent = '';

    handleActive(event) {
        const tab = event.target;
        this.tabContent = `Tab ${tab.value} is now active`;
    }
}