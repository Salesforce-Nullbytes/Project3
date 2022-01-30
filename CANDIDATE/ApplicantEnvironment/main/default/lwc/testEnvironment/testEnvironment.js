import { LightningElement, api } from 'lwc';
import submitResults from "@salesforce/apex/AsyncSendSubmissions.enqueueSubmission";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TestEnvironment extends LightningElement {

    @api questionList;
    question;
    questionIndex = 0;
    submissions;
    results;
    showResults;

    constructor(){
        super();
        this.submissions = {
            url : null,
            startTime : new Date(Date.now()),
            endTime : null,
            questions : []
        }
    }

    renderedCallback(){
        this.question = this.questionList.questions[this.questionIndex];
    }

    addSubmission(event){
        this.submissions.questions.push(event.detail);
        
        this.questionIndex+=1;

        if(this.questionIndex == this.questionList.questions.length){
            this.sendTestDataToClient();
            this.generateResultsReport();
            return;
        }

        this.setCurrentQuestion(this.questionList.questions[this.questionIndex]);
    }

    sendTestDataToClient(){
        this.submissions.endTime = new Date(Date.now());
        this.submissions.url = this.questionList.url;
        
        console.log("sending data to client...");
        console.log(this.submissions);

        submitResults({resultsParam: this.submissions}).then(() => {
            this.showSuccessToast();
        }).catch(error => {
            this.showErrorToast(error);
        });
    }

    setCurrentQuestion(question) {
        this.question = question; 
        let answerContainer = this.template.querySelector('c-answer-container');
        answerContainer.startQuestion(this.question);
    }

    generateResultsReport(){
        let results = {
            testname : this.questionList.name,
            percentage : null,
            timeTaken: this.getMinutesElapsed(this.submissions.startTime,this.submissions.endTime),
            questions : []
        }

        let totalPassed = 0;
        let totalTests = 0;

        this.submissions.questions.forEach(element => {
            let resultElement = {
                name: element.name,
                passed: 0,
                failed: 0,
                time: this.getMinutesElapsed(element.startTime, element.endTime),
                score: 0
            }
            element.methods.forEach(method =>{
                totalTests += 1;
                if(method.outcome == "PASS") {
                    totalPassed += 1;
                    resultElement.passed += 1;
                }
                else{
                    resultElement.failed += 1;
                }
            });
            let tests = resultElement.passed + resultElement.failed;
            resultElement.score = tests == 0 ? 0 : Math.round((resultElement.passed / tests)*100);
            results.questions.push(resultElement);
        });

        results.percentage = totalTests == 0 ? 0 : Math.round((totalPassed / totalTests)*100);

        this.results = results;
        this.showResults = true;

        console.log(results);
    }

    getMinutesElapsed(start, end){
        let diffMs = (end - start);
        return Math.round(((diffMs % 86400000) % 3600000) / 60000); // minutes
    }

    returnToQuestionExplorer(){
        this.showResults = false;
        let finishSetEvent = new CustomEvent('finishset');
        this.dispatchEvent(finishSetEvent);
    }

    showErrorToast(error){
        const event = new ShowToastEvent({
            title: 'ERROR',
            variant: 'error',
            message: error
        });
        this.dispatchEvent(event);
    }

    showSuccessToast() {
        const event = new ShowToastEvent({
            title: 'Results',
            variant: 'success',
            message:'Your results has been successfully submitted',
        });
        this.dispatchEvent(event);
    }
}