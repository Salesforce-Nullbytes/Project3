import { LightningElement, track } from 'lwc';
import Id from '@salesforce/user/Id';
//import Id from '@salesforce/community/Id';
import getCurrentUser from "@salesforce/apex/retrieveUserInfo.getCurrentUser";

export default class ClientHeader extends LightningElement {
    userId = Id;

    @track
    currentUser;

    connectedCallback(){
        //Get current user info
        getCurrentUser({userIdInfo: this.userId}).then(result => {
            this.currentUser = result;
        }).catch((error) => {
            console.log(error);
        });
    }
}