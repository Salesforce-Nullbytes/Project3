import { LightningElement,wire,track } from 'lwc';
import SiteUrl from '@salesforce/apex/AuthenticationController.SiteUrl';
import setSession from '@salesforce/apex/AuthenticationController.setSession';
import candidateLoginLogo from '@salesforce/resourceUrl/candidateLoginLogo';

export default class LoginPage extends LightningElement {
    @wire( SiteUrl )
    url;

    @track
    authCode = "";

    @track
    showError = false;

    @track
    errorText = "";

    candidateLogo = candidateLoginLogo;
    candidateCompanylogo ="candidateLogin Logo";

    get site() {
        return this.url.data + 'main/s/';
    }

    authCodeChange(event)
    {
        this.authCode = event.target.value;
        this.showError = false;
    }

    handleLogin(){
        //check auth code not blank
        if (this.authCode === "")
        {
            this.showError = true;
            this.errorText = "Please enter the authorization code";
            return;
        }

        let validation = false;
        console.log(this.authCode);

    //Call the apex controller method to set the session for the given authCode
        setSession({ code: this.authCode })
        .then((result) => {
            if (result) {
                validation = true;
                this.dispatchEvent(new CustomEvent('uservalidated', { detail: validation }));
            } else {
                this.showError = true;
                this.errorText =  "Server request failed";
                
            }
        })
        .catch((error) => {
            this.showError = true;
            this.errorText = "Could not connect with server.";
            console.log(error);
        });



    }

    


}