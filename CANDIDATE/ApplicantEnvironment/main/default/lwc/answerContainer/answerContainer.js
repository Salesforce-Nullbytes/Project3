import { LightningElement, api, track} from 'lwc';

import submitResponse from "@salesforce/apex/TestSubmitController.submitResponse";
import compileResponse from "@salesforce/apex/TestSubmitController.compileClass";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class AnswerContainer extends LightningElement {

    @api question;
    openModal = false;
    loading = false;
    startTime;

    //First question start time is null bc no call to startQuestion
    renderedCallback(){
        if(!this.startTime) this.startTime = this.getFormattedDateTime();
    }

    handleSubmission(event){
        

        let answerBox = this.template.querySelector('c-answer-box');
        let responseString = answerBox.getCandidateResponse();
        let isTrigger = this.question.topic == "Apex Triggers";

        this.openModal = false;
        this.loading = true;

        submitResponse({response: responseString, testClass: this.question.testFile, isTrigger: isTrigger}).then((result) =>{

            let submitResult = JSON.parse(result); // Result Type = SOAP-API CompileAndTestResult
            let testResult = submitResult.runTestsResult;
            let submissionElement = this.generateAPISubmissionElement(testResult);

            console.log(submitResult);

            // Test Environment handles compiling result data and changing questions
            let submission = new CustomEvent('submission',{detail: submissionElement});
            this.dispatchEvent(submission);

            this.showSuccessToast();

            this.loading = false;

        }).catch(error => {
            this.showErrorToast(error);
            this.loading = false;
        });
    }

    handleCodeRun(event){

        let answerBox = this.template.querySelector('c-answer-box');
        let resultBox = this.template.querySelector('c-result-box');
        let isTrigger = this.question.topic == "Apex Triggers";
        let responseString = answerBox.getCandidateResponse();

        resultBox.setAsLoading();
        
        compileResponse({response: responseString, isTrigger: isTrigger}).then((result) =>{

            let compileResult = JSON.parse(result)[0]; // Result Type = SOAP-API CompileTestResult

            let resultInfo = {
                success: compileResult.success,
                line: compileResult.line,
                column: compileResult.column,
                description: compileResult.problem
            }
            
            resultBox.setCompileResults(resultInfo);
            
        }).catch(error => {
            this.showErrorToast(error)
        });

    }

    @api startQuestion(question){
        this.question = question;
        this.startTime = this.getFormattedDateTime();
        let answerBox = this.template.querySelector('c-answer-box');
        let resultBox = this.template.querySelector('c-result-box');
        answerBox.method = this.question.placeholder;
        answerBox.reset();
        resultBox.reset();
    }

    //Build the object that the submission REST API Expects
    generateAPISubmissionElement(testResult){
        let submissionElement = {
            url : this.question.identifier,
            name : this.question.name,
            startTime : this.startTime,
            endTime : this.getFormattedDateTime(),
            methods : []
        }

        //We need the method name for API object, without testResults must be parsed out
        if(testResult.numTestsRun == 0){
            let isTestChunks = this.question.testFile.split('@isTest');
            isTestChunks.splice(0,2); //Remove class Declaration

            let methods = [];

            //Method name is the word between void and (
            isTestChunks.forEach(element => {
                let voidIndex = element.indexOf("void");
                let bracketIndex = element.indexOf("(");
                let subElement = element.substring(voidIndex,bracketIndex);
                let words = subElement.split(" ");
                let methodName = words[1];
                methods.push(methodName);
            });

            methods.forEach(method =>{
                let methodOutcome = {
                    name: method,
                    outcome : "FAIL"
                }

                submissionElement.methods.push(methodOutcome);
            })
        }
        
        if(testResult.successes){
            testResult.successes.forEach(element => {
                let methodOutcome = {
                    name: element.methodName,
                    outcome : "PASS"
                }

                submissionElement.methods.push(methodOutcome);
            });
        }
        
        if(testResult.failures){
            testResult.failures.forEach(element => {
                let methodOutcome = {
                    name: element.methodName,
                    outcome : "FAIL"
                }

                submissionElement.methods.push(methodOutcome);
            });
        }

        return submissionElement;
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

    showModal(){
        this.openModal = true;
    }

    closeModal(){
        this.openModal = false;
    }

    showSuccessToast() {
        const event = new ShowToastEvent({
            title: 'Submission',
            variant: 'success',
            message:'Your answer has been successfully submitted',
        });
        this.dispatchEvent(event);
    }

    showErrorToast(error){
        const event = new ShowToastEvent({
            title: 'ERROR',
            variant: 'error',
            message: error
        });
        this.dispatchEvent(event);
    }
}