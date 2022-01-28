import { LightningElement } from 'lwc';

export default class CodeAssessor extends LightningElement {

    credentials = false;

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