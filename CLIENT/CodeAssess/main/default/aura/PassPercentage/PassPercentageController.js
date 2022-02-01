//({
//    myAction : function(component, event, helper) {

//   }
//})

({
    doInit: function(component, event, helper) {
        helper.getPassPercentage(component);

    },
  

    searchPassPercentChange: function(component, event) {
        var searchPassPercentage = component.find("searchPassPercentage").get("v.value");
       
        //console.log('searchPercent:::::'+searchPercent);
        var action = component.get("c.findByPassPercentage");
        
        action.setParams({
            "searchPassPercentage": searchPassPercentage
            
        });

        action.setCallback(this, function(a) {
            component.set("v.passpercentages", a.getReturnValue());
        });
        
        $A.enqueueAction(action);
       
    }   
})
