import { LightningElement, api} from 'lwc';
import CodeAssessLogo from '@salesforce/resourceUrl/CodeAssesslogo';

export default class AuthLink extends LightningElement {

   CodeAssessLogo = CodeAssessLogo;

   @api
   siteUrl = '';
   @api
   clientKey = '';

   get auth() {
      return `${this.siteUrl}services/oauth2/authorize?response_type=code&client_id=${this.clientKey}&redirect_uri=${this.siteUrl}main/s/authorization`;
   }
}