import { LightningElement, api } from 'lwc';

// import submitResponse from "@salesforce/apex/TestSubmitController.submitResponse";
// import compileClass from "@salesforce/apex/TestSubmitController.compileClass";


export default class AnswerContainer extends LightningElement {

    @api question;

    handleSubmission(event){

        let testClass = "@isTest private class TestT1{" +
        "    public static testmethod void test1(){" +
        "      String s = C1.method1();" +
        "      System.assert(s=='HELLO');" +
        "    }" +
        "    public static testmethod void test2(){" +
        "      String s = C1.method1();" +
        "      System.assert(s=='Hi');" +
        "    }" +
        "}";

        let responseClass = "public class C1{" +
        "    public static String s ='HELLO';" +
        "    public static String method1(){" +
        "      return(s);" +
        "    }" +
        "}";

        let answerBox = this.template.querySelector('c-answer-box');
        let resultBox = this.template.querySelector('c-result-box');

        let responseString = answerBox.getCandidateResponse();

        resultBox.setAsLoading();
        
        submitResponse({response: responseClass, testClass: testClass}).then((result) =>{

            let submitResult = JSON.parse(result); // Result Type = SOAP-API CompileAndTestResult
            let resultInfo;

            console.log(submitResult);


            // If no tests were run there was a compilation error, we need to show those results instead.
            if(submitResult.runTestsResult.numTestsRun == 0){
                let compileResult = submitResult.classes[0];
                resultInfo = {
                    success: compileResult.success,
                    line: compileResult.line,
                    column: compileResult.column,
                    description: compileResult.problem
                }

                resultBox.setCompileResults(resultInfo);
            }
            else{
                let testResult = submitResult.runTestsResult;
                resultInfo = {
                    numTestsRun: testResult.numTestsRun,
                    numFailures: testResult.numFailures,
                    failures: testResult.failures,
                    successes: testResult.successes,
                    runtime: testResult.totalTime,
                    success: submitResult.success
                }

                resultBox.setSubmitResults(resultInfo);
            }

           

            
            
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
}