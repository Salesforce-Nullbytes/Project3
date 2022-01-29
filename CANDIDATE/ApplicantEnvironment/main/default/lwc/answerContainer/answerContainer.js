import { LightningElement, api } from 'lwc';

import submitResponse from "@salesforce/apex/TestSubmitController.submitResponse";
import compileResponse from "@salesforce/apex/TestSubmitController.compileClass";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class AnswerContainer extends LightningElement {

    @api question;
    openModal = false;
    loading = false;
    startTime;

    renderedCallback(){
        this.startTime = new Date(Date.now());
    }

    showModal(){
        this.openModal = true;
    }

    closeModal(){
        this.openModal = false;
    }

    handleSubmission(event){
        let testClass = '@isTest private class TestT1{' +
        '    public static testmethod void test1(){' +
        '      System.assert(warmup.myString=='+'\'HELLO\''+');' +
        '    }' +
        '}';
        let answerBox = this.template.querySelector('c-answer-box');
        let responseString = answerBox.getCandidateResponse();

        this.openModal = false;
        this.loading = true;

        submitResponse({response: responseString, testClass: testClass}).then((result) =>{

            let submitResult = JSON.parse(result); // Result Type = SOAP-API CompileAndTestResult
            let testResult = submitResult.runTestsResult;
            let submissionElement = {
                url : this.question.url,
                name : this.question.name,
                startTime : this.startTime,
                endTime : new Date(Date.now()),
                methods : []
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

        let responseString = answerBox.getCandidateResponse();

        resultBox.setAsLoading();
        
        compileResponse({response: responseString}).then((result) =>{

            let compileResult = JSON.parse(result)[0];

            console.log(compileResult);

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

    @api startQuestion(){
        this.startTime = new Date(Date.now());
        let answerBox = this.template.querySelector('c-answer-box');
        answerBox.reset();
    }

    showSuccessToast() {
        const event = new ShowToastEvent({
            title: 'Submission',
            variant: 'success',
            message:
                'Your answer has been successfully submitted',
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