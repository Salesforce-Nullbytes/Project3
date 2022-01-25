import { LightningElement, api } from 'lwc';

export default class QuestionExplorer extends LightningElement {
    @api tests = [
        {
            Id: "1",
            Name: "Account Trigger",
            Level: "Easy",
            Type: "Trigger"
        },
        {
            Id: "2",
            Name: "Order Trigger",
            Level: "Hard",
            Type: "Trigger"
        },
        {
            Id: "3",
            Name: "Unit Test",
            Level: "Medium",
            Type: "Test"
        }
    ];
}