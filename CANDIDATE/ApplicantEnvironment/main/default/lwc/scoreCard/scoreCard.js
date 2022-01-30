import { LightningElement } from 'lwc';

export default class ScoreCard extends LightningElement {
    totalScore ={testname: "Test1",
                 percentage:"95%" ,
                 timeTaken:"5 minutes", 
                 questions: [{name:"question name1",passed:3,failed:1,skipped:0,time:"1 minute",result:"Pass",score:0.75},
                 {name:"question name2",passed:2,failed:0,skipped:5,time:"2 minute",result:"Pass",score:0.35},
                 {name:"question name3",passed:7,failed:1,skipped:2,time:"10 minute",result:"Fail",score:0.1},
                 {name:"question name4",passed:2,failed:5,skipped:2,time:"2 minute",result:"Pass",score:0.75}] };

questionResults = this.totalScore.questions;
}