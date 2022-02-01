import { LightningElement, api } from 'lwc';

export default class QuestionCard extends LightningElement {
    @api questionSet;

    handleSolve() {
        const solveEvent = new CustomEvent('solvequestionset', {
            detail: this.questionSet
        });
        this.dispatchEvent(solveEvent);
        
    };
}