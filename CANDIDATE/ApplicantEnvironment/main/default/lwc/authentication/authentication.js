import { LightningElement, wire} from 'lwc';
import SiteUrl from '@salesforce/apex/AuthenticationController.SiteUrl';
import setSession from '@salesforce/apex/AuthenticationController.setSession';

export default class AuthLink extends LightningElement {
    @wire( SiteUrl )
    url;

    message='';

    get site() {
        return this.url.data+'main/s/';
    }
    get login() {
        return this.url.data+'main/s/login';
    }

    handleAuthenticate() {
        let code = this.template.querySelector('.input').value;

        setSession({ code: code })
        .then((result) => {
            if (result) {
                this.message = "Server request succeeded.";
            } else {
                this.message = "Server request failed.";
            }
        })
        .catch((error) => {
            this.message = 'Could not could not connect with server.';
        });
    }
}