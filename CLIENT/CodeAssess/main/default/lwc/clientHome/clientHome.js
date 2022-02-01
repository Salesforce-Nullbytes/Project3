import { api, LightningElement } from 'lwc';
import isGuest from '@salesforce/user/isGuest';
import { NavigationMixin } from 'lightning/navigation';

export default class ClientHome extends LightningElement {
    isGuestUser = isGuest;
    @api
    candidatePackageUrl;

    handleAuthClicked(event) {
        //TODO
    }

    handlePackageClicked(event) {
        //TODO
    }
}