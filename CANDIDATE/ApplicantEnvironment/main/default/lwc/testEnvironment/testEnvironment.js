import { LightningElement,api } from 'lwc';

export default class TestEnvironment extends LightningElement {

    @api question = {
        method: "public class MyClass {\n //Place code here \n}",
        name: "Account trigger",
        prompt: "Create account trigger"
    };

    addSubmission(event){
        console.log("Submitted");
    }
}