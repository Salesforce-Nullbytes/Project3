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
    questionTopic ='';
    questionName = '';
    questionPrompt = '';
    questionPlaceholder = '';
    recordId; //currently unused
    @track
    topicOptions;
    disabledAllBool = false;
    loadingBool = false;
    placeholderFileData;

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
            this.loadingBool = false;
        }
        this.loadingBool = true;
        reader.readAsDataURL(uFile);
    }

    handlePlaceholderFileUpload(event) {
        const uFile2 = event.target.files[0];
        let reader2 = new FileReader();
        reader2.onload = () => {
            let phbase64 = reader2.result.split(',')[1];
            this.placeholderFileData = {
                'fileName': uFile2.name,
                'base64': phbase64
            }
            this.loadingBool = false;
        }
        this.loadingBool = true;
        reader2.readAsDataURL(uFile2);
        this.template.querySelector('.classPlaceholderInput').disabled = true;
    }

    handleTopicSelection(event) {
        this.questionTopic = event.detail.value;
    }

    handleSubmitClicked() {
        this.loadingBool = true;
        this.disableAllInput();

        //check if all fields are populated correctly
        if (!this.fileData || !this.questionTopic || !this.questionPrompt || !this.questionName) {
            this.showAlert('Error', 'Required fields not populated!', 'error');
            return;
        }
        
        CheckNameCollision({name: this.questionTopic.replace(' ', '_') + '_' + this.fileData['fileName'], qName: this.questionName}).then(result => {
            if (result) {
                this.showAlert('Error', 'There is already a question or file name + category combination with the same name!', 'error');
                return;
            }
            
            let passPlaceholder = this.questionPlaceholder;
            if (this.placeholderFileData) {
                passPlaceholder = atob(this.placeholderFileData['base64']);
                
            }
            InsertQuestion({qName: this.questionName, topic: this.questionTopic, placeholder: passPlaceholder, prompt: this.questionPrompt, rawText: this.fileData['base64']}).then(result => {
                this.recordId = result;
                LinkFile({base64: this.fileData['base64'], filename: this.questionTopic.replace(' ', '_') + '_' + this.fileData['fileName'], recordId: this.recordId}).then(result => {

                    if (result == 'success') {
                        this.showAlert('Success', 'Question successfully created!', 'success');
                        this.questionName = '';
                        this.questionPlaceholder = '';
                        this.questionPrompt = '';
                        this.questionTopic = '';
                        this.fileData = null;
                        this.placeholderFileData = null;
                        this.template.querySelector('.classPlaceholderInput').disabled = false;
                    } else {
                        this.showAlert('Error', 'An error occured: ' + result, 'error');
                    }
                });
                
            });
    
        });
        
    }

    disableAllInput() {
        this.disabledAllBool = true;
    }

    enableAllInput() {
        this.disabledAllBool = false;
    }

    showAlert(alertTitle, alertMessageStr, variant) {
        this.alertMessageStr = alertMessageStr;
        let event = new ShowToastEvent({
            title: alertTitle,
            message: alertMessageStr,
            variant: variant
        });
        this.dispatchEvent(event);

        this.disabledAllBool = false;
        this.loadingBool = false;

        this.enableAllInput();
    }

    handlePlaceholderPillRemove() {
        this.placeholderFileData = null;
        this.template.querySelector('.classPlaceholderInput').disabled = false;
    }

    handleTestClassPillRemove() {
        this.fileData = null;
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