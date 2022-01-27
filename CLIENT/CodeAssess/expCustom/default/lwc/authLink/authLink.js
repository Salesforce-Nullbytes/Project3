import { LightningElement, api} from 'lwc';
// import { CurrentPageReference } from 'lightning/navigation';

export default class AuthLink extends LightningElement {

   @api
   siteUrl = '';
   @api
   clientKey = '';

   get auth() {
      return `${this.siteUrl}services/oauth2/authorize?response_type=code&client_id=${this.clientKey}&redirect_uri=${this.siteUrl}main/s/authorization`;
   }

   // currentPageReference = null; 
   // urlStateParameters = null;

   // authCode = null;

   // @wire(CurrentPageReference)
   // getStateParameters(currentPageReference) {
   //    if (currentPageReference) {
   //       this.urlStateParameters = currentPageReference.state;
   //       this.setParametersBasedOnUrl();
   //    }
   // }

   // setParametersBasedOnUrl() {
   //    this.authCode = this.urlStateParameters.code || 'Authorization Code Unavailable';
   // }

   // get authCode() {
   //    return this.authCode;
   // }
}