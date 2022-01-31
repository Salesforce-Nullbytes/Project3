import { LightningElement, track } from 'lwc';
import getCurrentUser from "@salesforce/apex/retrieveUserInfo.getCurrentUser";

export default class ClientHeader extends LightningElement {
    @track
    currentUser;

    connectedCallback(){
        //Get current user info
        getCurrentUser().then(result => {
            this.currentUser = result;
        }).catch((error) => {
            console.log(error);
        });
    }
}