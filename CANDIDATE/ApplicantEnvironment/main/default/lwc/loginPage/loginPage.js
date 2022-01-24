import { LightningElement, track } from 'lwc';

export default class LoginPage extends LightningElement {

    @track
    username;
    
    @track
    password;
    
    @track
    showError = false;
    
    @track
    errorText = "";
    
        usernameChange(event)
        {
            this.username = event.target.value;
            this.showError = false;
        }
        passwordChange(event)
        {
            this.password = event.target.value;
            this.showError = false;
        }
    
        handleLogin(){
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
    
        }

}