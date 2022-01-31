//({
//    myAction : function(component, event, helper) {

//   }
//})

({
    doInit: function(component, event, helper) {
        helper.getPassPercentageList(component);

    },
  

    searchKeyChange: function(component, event) {
        var searchKey = component.find("searchPercent").get("v.value");
       
        //console.log('searchPercent:::::'+searchPercent);
        var action = component.get("c.findByPercent");
        
        action.setParams({
            "searchPercent": searchPercent
            
        });

        action.setCallback(this, function(a) {
            component.set("v.passpercentages", a.getReturnValue());
        });
        
        $A.enqueueAction(action);
       
    }   
})
