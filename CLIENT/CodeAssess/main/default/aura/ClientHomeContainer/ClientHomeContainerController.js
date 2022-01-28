({
    doInit : function(component, event, helper){
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.userId", userId);
        component.set("v.showHome", "true");
        component.set("v.showTestSummary", "false");
    },
    startExam : function(component, event, helper){
        //Get current test summarry setting
        let showTestSummaryValue = component.get("v.showTestSummary");

        //If previous test tab selected
        if(showTestSummaryValue === "true"){
            //Home tab focus style, previous tab unfocus
            var homeButtonElem = component.find('startExamButton');
            var resultButtonElem = component.find('viewResultButton');
            $A.util.removeClass(resultButtonElem, 'bgrFocus');
            $A.util.removeClass(homeButtonElem, 'bgrNonFocus');
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
        if(showTestSummaryValue === "false"){
            //Home tab unfocus style, previous tab focus style
            var homeButtonElem = component.find('startExamButton');
            var resultButtonElem = component.find('viewResultButton');
            $A.util.addClass(resultButtonElem, 'bgrFocus');
            $A.util.addClass(homeButtonElem, 'bgrNonFocus');
        }

        //Set start test home display as false
        component.set("v.showHome", "false");

        //Set test summary display as true
        component.set("v.showTestSummary", "true");
    }
})
