import { LightningElement, track } from 'lwc';
import InsertQuestion from '@salesforce/apex/testQuestionCreatorController.insertQuestion';
import CheckNameCollision from '@salesforce/apex/testQuestionCreatorController.checkNameCollision';
import LinkFile from '@salesforce/apex/testQuestionCreatorController.linkFile';
import GetPicklist from '@salesforce/apex/testQuestionCreatorController.topicPicklistValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TestQuestionCreator extends LightningElement {
    //holds uploaded file's data
    @track
    fileData;
    questionTopic;
    questionName;
    questionPrompt;
    questionPlaceholder;
    recordId; //currently unused
    @track
    topicOptions;
    disabledAllBool = false;
    loadingBool = false;

    constructor() {
        super();
        GetPicklist().then(result => {
            let returnArr = [];
            result.forEach(item => {
                returnArr.push({label: item, value: item});
            })

            this.topicOptions = returnArr;
            
        });
    }

    handleFileUpload(event) {
        //instantiate file variable and reader instance
        const uFile = event.target.files[0];
        let reader = new FileReader();
        reader.onload = () => {
            let base64 = reader.result.split(',')[1];
            this.fileData = {
                'fileName': uFile.name,
                'base64': base64
            }
        }
        reader.readAsDataURL(uFile);
    }

    handleTopicSelection(event) {
        this.questionTopic = event.detail.value;
    }

    handleSubmitClicked() {
        this.loadingBool = true;
        this.disableAllInput();

        //check if all fields are populated correctly
        if (!this.fileData || !this.questionTopic || !this.questionPrompt || !this.questionName) {
            this.showAlert('Error', 'Required fields not populated!');
            return;
        }
        
        CheckNameCollision({name: this.questionTopic.replace(' ', '_') + '_' + this.fileData['fileName'], qName: this.questionName}).then(result => {
            if (result) {
                this.showAlert('Error', 'There is already a question or file name + category combination with the same name!');
                return;
            }
    
            InsertQuestion({qName: this.questionName, topic: this.questionTopic, placeholder: this.questionPlaceholder, prompt: this.questionPrompt, rawText: this.fileData['base64']}).then(result => {
                this.recordId = result;

                console.log(this.fileData['base64']);
                console.log(this.questionTopic.replace(' ', '_') + '_' + this.fileData['fileName']);
                LinkFile({base64: this.fileData['base64'], filename: this.questionTopic.replace(' ', '_') + '_' + this.fileData['fileName'], recordId: this.recordId}).then(result => {

                    if (result == 'success') {
                        this.showAlert('Success', 'Question successfully created!');
                    } else {
                        this.showAlert('Error', 'An error occured: ' + result);
                    }
                });
                
            });
    
        });
        
    }

    disableAllInput() {
        this.disabledAllBool = true;
        this.template.querySelector('lightning-textarea').setAttribute('disabled', '');
        this.template.querySelector('lightning-combobox').setAttribute('disabled', '');
        this.template.querySelector('lightning-input').setAttribute('disabled', '');
        this.template.querySelector('lightning-button').setAttribute('disabled', '');
    }

    enableAllInput() {
        this.disabledAllBool = false;
        this.template.querySelector('lightning-textarea').removeAttribute('disabled');
        this.template.querySelector('lightning-combobox').removeAttribute('disabled');
        this.template.querySelector('lightning-input').removeAttribute('disabled');
        this.template.querySelector('lightning-button').removeAttribute('disabled');
    }

    showAlert(alertTitle, alertMessageStr) {
        this.alertMessageStr = alertMessageStr;
        let event = new ShowToastEvent({
            title: alertTitle,
            message: alertMessageStr
        });
        this.dispatchEvent(event);

        this.disabledAllBool = false;
        this.loadingBool = false;

        this.enableAllInput();
    }

    handlePromptInput(event) {
        this.questionPrompt = event.detail.value;
    }

    handlePlaceholderInput(event) {
        this.questionPlaceholder = event.detail.value;
    }

    handleNameInput(event) {
        this.questionName = event.detail.value;
    }
}