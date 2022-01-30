import { api, LightningElement } from 'lwc';

export default class ResultBox extends LightningElement {

    results;
    showCompileResults = false;
    showResults = false;
    toggleLabel = "utility:chevronup";
    loading = false;

    @api setCompileResults(resultsInfo){
        this.results = resultsInfo;
        this.loading = false;
        this.showCompileResults = true;
    }

    @api setAsLoading(){
        this.showResults = true;
        this.toggleLabel = "utility:chevrondown";
        this.loading = true;
    }

    @api reset(){
        if(this.showResults) this.toggleResultsPanel();
        this.results = null;
        this.showCompileResults = false;
    }

    toggleResultsPanel(){
        this.showResults = !this.showResults;
        this.toggleLabel = this.toggleLabel == "utility:chevrondown" ? "utility:chevronup" : "utility:chevrondown";
    }
}