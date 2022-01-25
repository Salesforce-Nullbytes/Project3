import { LightningElement, api } from 'lwc';
import submitResponse from "@salesforce/apex/TestSubmitController.submitResponse";
import compileClass from "@salesforce/apex/TestSubmitController.compileClass";

export default class AnswerContainer extends LightningElement {

    @api question;

    handleSubmission(event){
        let testClass = '@isTest private class TestT1{' +
        '    public static testmethod void test2(){' +
        '      String s = C1.method1();' +
        '      System.assert(s=="HELLO");' +
        '    }' +
        '}';

        let responseClass = 'public class C1{' +
        '    public static String s ="HELLO";' +
        '    public static String method1(){' +
        '      return(s);' +
        '    }' +
        '}';

        submitResponse(responseClass,testClass).then((result) =>{
            console.log(result);
        })

        console.log("We be submitted");
    }

    handleCodeRun(event){
        
        let responseClass = 'public class C1{' +
        '    public static String s ="HELLO";' +
        '    public static String method1(){' +
        '      return(s);' +
        '    }' +
        '}';
        compileClass(responseClass).then((result) =>{
            console.log(result);
        });

        console.log("Running some code...");
    }
}