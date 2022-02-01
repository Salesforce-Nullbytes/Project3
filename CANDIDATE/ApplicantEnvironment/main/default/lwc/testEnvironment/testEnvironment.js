import { LightningElement, api } from 'lwc';
import submitResults from "@salesforce/apex/RESTcallout.postSubmission";
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
            startTime : this.getFormattedDateTime(),
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
        this.submissions.endTime = this.getFormattedDateTime();
        this.submissions.url = this.questionList.url;

        submitResults({jsonBody: JSON.stringify(this.submissions)}).then((result) => {
            console.log(result);
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
            timeTaken: this.getMinutesElapsed(new Date(this.submissions.startTime),new Date(this.submissions.endTime)),
            questions : []
        }

        let totalPassed = 0;
        let totalTests = 0;

        this.submissions.questions.forEach(element => {

            let testTime = new Date(element.startTime);
            console.log("Time: "+testTime);

            let resultElement = {
                name: element.name,
                passed: 0,
                failed: 0,
                time: this.getMinutesElapsed(new Date(element.startTime), new Date(element.endTime)),
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
            //resultElement.name = ""+resultElement.passed + resultElement.failed + resultElement.time + resultElement.score;
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

    addLeadingZeros(n) {
        if (n <= 9) {
          return "0" + n;
        }
        return n
    }

    getFormattedDateTime(){
        let currentDatetime = new Date(Date.now())
        return currentDatetime.getFullYear() + "-" + this.addLeadingZeros(currentDatetime.getMonth() + 1) + "-" + this.addLeadingZeros(currentDatetime.getDate()) + " " + this.addLeadingZeros(currentDatetime.getHours()) + ":" + this.addLeadingZeros(currentDatetime.getMinutes()) + ":" + this.addLeadingZeros(currentDatetime.getSeconds())
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