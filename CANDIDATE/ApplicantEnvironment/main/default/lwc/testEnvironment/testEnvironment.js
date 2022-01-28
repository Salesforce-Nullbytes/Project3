import { LightningElement, api } from 'lwc';

export default class TestEnvironment extends LightningElement {

    @api questionList;
    question;
    questionIndex = 0;
    submissions = [];

    renderedCallback(){
        console.log(this.questionList);
        this.question = this.questionList.questions[this.questionIndex];
        
    }

    addSubmission(event){
        console.log("Submitted");
        this.submissions.push(event.detail);
        
        this.questionIndex+=1;

        if(this.questionIndex == this.questionList.questions.length){
            this.sendTestDataToClient();

            let finishSetEvent = new CustomEvent('finishset');
            this.dispatchEvent(finishSetEvent);
            return;
        }

        this.setQuestion(this.questionList.questions[this.questionIndex]);
    }

    sendTestDataToClient(){
        console.log("sending data to client...");
    }

    setQuestion(question) {
        this.question = question;
        let answerContainer = this.template.querySelector('c-answer-container');
        answerContainer.startQuestion(question);
    }
}