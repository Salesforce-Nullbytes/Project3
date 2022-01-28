import { LightningElement, api } from 'lwc';
import submitResponse from "@salesforce/apex/TestSubmitController.submitResponse";
import compileResponse from "@salesforce/apex/TestSubmitController.compileClass";

export default class AnswerContainer extends LightningElement {

    @api question;
    openModal = false;
    loading = false;
    startTime;

    showModal(){
        this.openModal = true;
    }

    closeModal(){
        this.openModal = false;
    }

    handleSubmission(event){
        let testClass = '@isTest private class TestT1{' +
        '    public static testmethod void test1(){' +
        '      System.assert(warmup.myString==\'HELLO\');' +
        '    }' +
        '}';

        this.openModal = false;
        this.loading = true;

        let answerBox = this.template.querySelector('c-answer-box');
        let resultBox = this.template.querySelector('c-result-box');

        let responseString = answerBox.getCandidateResponse();
        
        submitResponse({response: responseString, testClass: testClass}).then((result) =>{

            let submitResult = JSON.parse(result); // Result Type = SOAP-API CompileAndTestResult
            let compileResult = submitResult.classes[0];
            let testResult = submitResult.runTestsResult;
            let resultInfo = {
                compilationError: false,
                errorResult: {
                    line: compileResult.line,
                    column: compileResult.column,
                    description: compileResult.problem
                },
                numTestsRun: testResult.numTestsRun,
                numFailures: testResult.numFailures,
                failures: testResult.failures, //failures/success descripe the specific methods results in detail
                successes: testResult.successes,
                runtime: testResult.totalTime,
                success: submitResult.success,
                startTime: this.startTime, //Times are server miliseconds format, not DateTime
                endTime: Date.now(), 
                testId: null
            }

            console.log(submitResult);

            //If no tests are run then there was a compilation error
            if(submitResult.runTestsResult.numTestsRun == 0) resultInfo.compilationError = true;

            // Test Environment handles compiling result data and changing questions
            let submission = new CustomEvent('submission',{detail: resultInfo});

            this.dispatchEvent(submission);

            this.loading = false;

        }).catch(error => console.log(error));
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
            
        }).catch(error => console.log(error));

    }

    @api startQuestion(question){
        //this.question = question;
        this.startTime = Date.now();
    }
}