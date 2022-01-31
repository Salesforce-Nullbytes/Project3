import { LightningElement } from 'lwc';
import isAuth from "@salesforce/apex/AuthenticationController.isAuthenticated";

export default class CodeAssessor extends LightningElement {

    credentials = false;

    constructor(){
        super();
        this.credentials = isAuth();
    }

    /*getUserDetails(event)
    {
        let userDetails = event.detail;
        console.log("user ID:" + userDetails[0].Id);
        console.log("user Name:" + userDetails[0].name);
        //Once user details are received, credentials need to be set to true
        //this.credentials = true;
    }*/

    handleUserValidated(event)
    {
        this.credentials = event.detail;
    }

}