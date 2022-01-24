import { LightningElement } from 'lwc';
import InsertQuestion from '@salesforce/apex/testQuestionCreatorController.insertQuestion';
import CheckNameCollision from '@salesforce/apex/testQuestionCreatorController.checkNameCollision';

export default class TestQuestionCreator extends LightningElement {
    //holds uploaded file's data
    fileData;

    fileTopic;

    recordId;

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
            console.log(this.fileData);
        }
        reader.readAsDataURL(this.fileData);
    }

    get topicOptions() {
        //implement this once ca
    }

    handleTopicSelection(event) {
        this.fileTopic = event.detail.fileTopic;
    }

    handleSubmitClicked() {
        const {base64, filename, recordId} = this.fileData;

        CheckNameCollision({name: this.fileTopic + '_' + this.fileData['fileName']}).then(result => {
            //implement code for when naming collision exists
            return;
        });

        InsertQuestion({base64, filename, recordId}).then(result => {

        });
    }
}