import { LightningElement, track } from 'lwc';

export default class LoginPage extends LightningElement {

   //@track
//username;

//@track
//password;

@track
authCode = "";

@track
showError = false;

@track
errorText = "";

    /*usernameChange(event)
    {
        this.username = event.target.value;
        this.showError = false;
    }
    passwordChange(event)
    {
        this.password = event.target.value;
        this.showError = false;
    }*/

    authCodeChange(event)
    {
        this.authCode = event.target.value;
        this.showError = false;
    }

    /*handleLogin(){
        let name= "project3";
        let pass = "project3";
        this.showError = false;
        console.log("username is "+this.username);
        console.log("password is "+this.password);
        if(this.username===name && this.password===pass){

            let userinfo = [{Id:"1", name:"user1"}];
            this.dispatchEvent(new CustomEvent('userdetails', { detail: userinfo }));

        }
        else{

            this.showError = true;
            this.errorText = "Username and password does not exist";
        } 

    }*/

    handleLogin(){
        //check auth code not blank
        if (this.authCode === "")
        {
            this.showError = true;
            this.errorText = "Please enter the authorization code";
            return;
        }

        let validation = false;

        //we have an authorization code. call the apex class passing the auth code to get token and save it
        //if the function return true it means validation done. Dispatch uservalidated event to parent
        //for testing to be removed after actual apex call
        if (this.authCode === "abcdef")
            validation = true;

        if (validation === true)
        {
            this.dispatchEvent(new CustomEvent('uservalidated', { detail: validation }));
        }
    }


}