import { LightningElement, api } from 'lwc';

export default class answerBox extends LightningElement {
    @api method;
    @api response;


    reset(){
       var val = this.template.ShadowRoot.queryselector("size").value;
       val = this.method_signature;
    }
    
    sendUp(event){
        var pass;
        pass = event.target.value;
        this.response = pass;
        console.log(this.response);
    }
}