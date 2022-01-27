({
    homeInit : function(component, event, helper){
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.userId", userId);
        component.set("v.showHome", "true");
        component.set("v.showTestSummary", "false");
        let homeButtonElem = component.find('startExamButton');
        $A.util.addClass(homeButtonElem, 'bgrFocus');
    },
    startExam : function(component, event, helper){
        //Get current test summarry setting
        let showTestSummaryValue = component.get("v.showTestSummary");

        //If test summary tab selected
        if(showTestSummaryValue === true){
            let homeButtonElem = component.find('startExamButton');
            let resultButtonElem = component.find('viewResultButton');
            $A.util.removeClass(resultButtonElem, 'bgrFocus');
            $A.util.addClass(homeButtonElem, 'bgrFocus');
        }

        //Set start test home display as true
        component.set("v.showHome", "true");

        //Set test summary display as false
        component.set("v.showTestSummary", "false");
        
    },
    viewResults : function(component, event, helper){
        //Get current test summarry setting
        let showTestSummaryValue = component.get("v.showTestSummary");

        //If test home tab selected
        if(showTestSummaryValue === true){
            let homeButtonElem = component.find('startExamButton');
            let resultButtonElem = component.find('viewResultButton');
            $A.util.addClass(resultButtonElem, 'bgrFocus');
            $A.util.removeClass(homeButtonElem, 'bgrFocus');
        }

        //Set start test home display as false
        component.set("v.showHome", "false");

        //Set test summary display as true
        component.set("v.showTestSummary", "true");
    }
})
