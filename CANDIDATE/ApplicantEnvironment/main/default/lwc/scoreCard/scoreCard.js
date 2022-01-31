import { LightningElement, track, api } from 'lwc';

export default class ScoreCard extends LightningElement {
    /*totalScore ={testname: "Test1",
                 percentage:"95%" ,
                 timeTaken:"5 minutes", 
                 questions: [{name:"question name1",passed:3,failed:1, time:"1 minute",score:75},
                 {name:"question name2",passed:2,failed:0,time:"2 minute",score:35},
                 {name:"question name3",passed:7,failed:1,time:"10 minute",score:10},
                 {name:"question name4",passed:2,failed:5,time:"2 minute",score:75}] };*/

    @api
    totalScore;

    @track
    questionResults = [];

    connectedCallback()
    {
        if ("questions" in this.totalScore)
        {
            this.questionResults = this.totalScore.questions;
        }
        else
        {
            this.questionResults = [];
        }
        
    }
}