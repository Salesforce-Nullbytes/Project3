import { api, LightningElement, track } from 'lwc';
import getCandidateTestResults from '@salesforce/apex/candidateInformationController.getCandidateTestResults';

export default class candidateChart extends LightningElement {
    @api recordId;

    //values affecting graph size
    graphCenter = [200, 200];
    @api
    baseGraphSize = 5;
    @api
    graphSegments = 5;
    @api
    graphSegmentSize = 20;
    @api
    graphSize = 400;
    @api
    graphColor = '#5DFFF8B3';

    //values affecting graph values
    @track
    statList = []; //util, phys off, phys def, mag def, mag off

    @track
    statNamesList = [];

    //average scores for each topic
    apexTriggersScore = 0;
    auraComponentsScore = 0;
    eventsScore = 0;
    lwcScore = 0;
    soqlScore = 0;
    soslScore = 0;

    //keep track of how many scores in each topic for average
    apexTriggersCount = 0;
    auraComponentsCount = 0;
    eventsCount = 0;
    lwcCount = 0;
    soqlCount = 0;
    soslCount = 0;

    count = 0;




    loadSummary() {
        getCandidateTestResults({record : this.recordId})
        .then((result) => {

            // gather totals for each question topic
            for (let i = 0; i < result.length; i++) {
                switch (result[i].Question__r.QuestionTopic__c) {
                    case "Apex Triggers":
                        this.apexTriggersScore += (result[i].MethodsPassed__c / result[i].TotalMethods__c * 100);
                        this.apexTriggersCount++;
                        break;
                    case "Aura Components":
                        this.auraComponentsScore += (result[i].MethodsPassed__c / result[i].TotalMethods__c * 100);
                        this.auraComponentsCount++;
                        break;
                    case "Events":
                        this.eventsScore += (result[i].MethodsPassed__c / result[i].TotalMethods__c * 100);
                        this.eventsCount++;
                        break;
                    case "LWC":
                        this.lwcScore += (result[i].MethodsPassed__c / result[i].TotalMethods__c * 100);
                        this.lwcCount++;
                        break;
                    case "SOQL":
                        this.soqlScore += (result[i].MethodsPassed__c / result[i].TotalMethods__c * 100);
                        this.soqlCount++;
                        break;
                    case "SOSL":
                        this.soslScore += (result[i].MethodsPassed__c / result[i].TotalMethods__c * 100);
                        this.soslCount++;
                        break;
                    default:
                        console.log("Error: Unrecognized topic");
                }
            }

            //add to chart lists
            if (this.apexTriggersCount > 0) {
                this.statNamesList[this.count] = "Apex Triggers";
                this.statList[this.count] = this.apexTriggersScore / this.apexTriggersCount;
                this.count++;
            }

            if (this.auraComponentsCount > 0) {
                this.statNamesList[this.count] = "Aura Components";
                this.statList[this.count] = this.auraComponentsScore / this.auraComponentsCount;
                this.count++;
            }

            if (this.eventsCount > 0) {
                this.statNamesList[this.count] = "Events";
                this.statList[this.count] = this.eventsScore / this.eventsCount;
                this.count++;
            }

            if (this.lwcCount > 0) {
                this.statNamesList[this.count] = "LWC";
                this.statList[this.count] = this.lwcScore / this.lwcCount;
                this.count++;
            }

            if (this.soqlCount > 0) {
                this.statNamesList[this.count] = "SOQL";
                this.statList[this.count] = this.soqlScore / this.soqlCount;
                this.count++;
            }

            if (this.soslCount > 0) {
                this.statNamesList[this.count] = "SOSL";
                this.statList[this.count] = this.soslScore / this.soslCount;
                this.count++;
            }

            //draw graph
            this.graphCenter[0] = Math.round(this.graphSize/2);
            this.graphCenter[1] = Math.round(this.graphSize/2);
            this.drawStatGraph();
            
        })
        .catch((error) => {
            console.log("Failure");
        });
    }

    renderedCallback() {
        
        this.loadSummary();
        this.componentRendered = true;
    }

    @api
    drawStatGraph() {
        let canvas = this.template.querySelector('.statgraph');

        let numStats = this.statList.length;
        let degreeChange = 360/numStats;

        //check if browser supports canvas feature
        if (canvas.getContext) {
            //canvas setup
            let context = canvas.getContext('2d');

            //clear canvas for redraws
            context.clearRect(0, 0, canvas.width, canvas.height);
            context.fillStyle = 'Black';

            //draw stat graph outline
            context.strokeStyle = 'Grey';
            let rollingDegrees = -90;
            for (let increment = this.graphSegmentSize + this.baseGraphSize; increment <= (this.graphSegmentSize * this.graphSegments) + this.baseGraphSize; increment += this.graphSegmentSize) {
                context.beginPath();
                for(let index = 0; index < numStats; index++) {
                    //calculate x and y
                    let x = increment * Math.cos(rollingDegrees * (Math.PI/180));
                    let y = increment * Math.sin(rollingDegrees * (Math.PI/180));
    
                    context.lineTo(this.graphCenter[0] + x, this.graphCenter[1] + y);
                    if (increment === ((this.graphSegmentSize * this.graphSegments) + this.baseGraphSize)) {

                        if(numStats % 2 === 0) {
                            //even numstats
                            if(index === 0 || index === numStats/2) {
                                context.textAlign = 'center';
                            } else if (index < numStats/2) {
                                context.textAlign = 'start';
                            } else {
                                context.textAlign = 'end';
                            }
                        } else {
                            //odd numstats
                            if(index === 0) {
                                context.textAlign = 'center';
                            } else if (index <= numStats/2) {
                                context.textAlign = 'start';
                            } else {
                                context.textAlign = 'end';
                            }
                        }
                        context.fillText(this.statNamesList[index], this.graphCenter[0] + (x * 1.08), this.graphCenter[1] + (y * 1.08));
                    }
                    
                    //increment rolling degrees
                    rollingDegrees += degreeChange;
                }
                
                context.closePath();
                context.stroke();
            }
            

            //draw stat graph
            context.fillStyle = this.graphColor;
            context.beginPath();
            
            rollingDegrees = -90;
            for(let index = 0; index < numStats; index++) {
                //calculate x and y
                let x = (this.statList[index] + this.baseGraphSize) * Math.cos(rollingDegrees * (Math.PI/180));
                let y = (this.statList[index] + this.baseGraphSize) * Math.sin(rollingDegrees * (Math.PI/180));

                context.lineTo(this.graphCenter[0] + x, this.graphCenter[1] + y);

                //increment rolling degrees
                rollingDegrees += degreeChange;
            }
            
            context.fill();
            context.closePath();
            
        } else {
            //TODO write code for when browser does not support canvas
        }
    }
}