import { LightningElement, api } from 'lwc';

export default class answerBox extends LightningElement {
    @api method;

    @api
    reset(){
        let textarea = this.template.querySelector('textarea');
        textarea.value = this.method;
    }

    @api 
    getCandidateResponse(){
        return this.template.querySelector('textarea').value;
    }

    handleTabs(e){
        
        if (e.keyCode === 9) {
            e.preventDefault();
            
            let field = e.target;
            let val = field.value;
            let start = field.selectionStart;
            let end = field.selectionEnd;

            // set textarea value to: text before caret + tab + text after caret
            field.value = val.substring(0, start) + '\t' + val.substring(end);

            // put caret at right position again
            field.selectionStart = field.selectionEnd = start + 1;

            // prevent the focus lose
            return false;

        }
    }
}