import { LightningElement, track } from 'lwc';
import InsertQuestion from '@salesforce/apex/testQuestionCreatorController.insertQuestion';
import CheckNameCollision from '@salesforce/apex/testQuestionCreatorController.checkNameCollision';
import LinkFile from '@salesforce/apex/testQuestionCreatorController.linkFile';

export default class TestQuestionCreator extends LightningElement {
    //holds uploaded file's data
    @track
    fileData;
    fileTopic;
    questionName;
    questionPrompt;
    questionPlaceholder;
    recordId; //currently unused

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

    get topicOptions() {
        //TODO implement this once topics are implemented in ERD
    }

    handleTopicSelection(event) {
        this.fileTopic = event.detail.value;
    }

    handleSubmitClicked() {
        //check if all fields are populated correctly
        if (!this.fileData || !this.fileTopic || !this.questionPrompt || !this.questionName) {
            //TODO implement some kind of visual feedback that the submission failed due to missing fields
            console.log('no');
            return;
        }

        let nameCollision;
        CheckNameCollision({name: this.fileTopic + '_' + this.fileData['fileName'] + '.cls', qName: this.questionName}).then(result => {
            nameCollision = result;
        });

        if (nameCollision) {
            //TODO implement code for when naming collision
            return;
        }

        InsertQuestion({qName,  topic,  placeholder,  prompt}).then(result => {
            this.recordId = result;
        });

        let linkSuccess;
        LinkFile({base64: this.fileData['base64'], filename: this.fileTopic + '_' + this.fileData['fileName'], recordId: this.recordId}).then(result => {
            linkSuccess = result;
        });

        if (linkSuccess) {
            //TODO provide visual feedback on success
            console.log('yay');
        } else {
            //TODO provide visual feedback on failure
            console.log('sadge');
        }

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