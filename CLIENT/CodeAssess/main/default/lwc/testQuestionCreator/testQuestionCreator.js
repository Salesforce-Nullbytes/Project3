import { LightningElement, track } from 'lwc';
import InsertQuestion from '@salesforce/apex/testQuestionCreatorController.insertQuestion';
import CheckNameCollision from '@salesforce/apex/testQuestionCreatorController.checkNameCollision';
import LinkFile from '@salesforce/apex/testQuestionCreatorController.linkFile';
import GetPicklist from '@salesforce/apex/testQuestionCreatorController.topicPicklistValues';

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
        //check if all fields are populated correctly
        if (!this.fileData || !this.questionTopic || !this.questionPrompt || !this.questionName) {
            //TODO implement some kind of visual feedback that the submission failed due to missing fields
            return;
        }

        CheckNameCollision({name: this.questionTopic.replace(' ', '_') + '_' + this.fileData['fileName'], qName: this.questionName}).then(result => {
            //TODO create some kind of visual feedback to show while calls are still being resolved
            if (result) {
                //TODO implement code for when naming collision
                console.log('collision');
                return;
            }
    
            InsertQuestion({qName: this.questionName, topic: this.questionTopic, placeholder: this.questionPlaceholder, prompt: this.questionPrompt, rawText: this.fileData['base64']}).then(result => {
                this.recordId = result;

                console.log(this.fileData['base64']);
                console.log(this.questionTopic.replace(' ', '_') + '_' + this.fileData['fileName']);
                LinkFile({base64: this.fileData['base64'], filename: this.questionTopic.replace(' ', '_') + '_' + this.fileData['fileName'], recordId: this.recordId}).then(result => {

                    if (result == 'success') {
                        //TODO provide visual feedback on success
                    } else {
                        //TODO provide visual feedback on failure
                        console.log(result);
                    }
                });
                
            });
    
        });
        
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