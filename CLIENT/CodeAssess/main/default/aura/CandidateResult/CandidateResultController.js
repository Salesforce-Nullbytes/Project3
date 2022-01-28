//({
 //   myAction : function(component, event, helper) {

//    }
//})
({
    doInit: function(component, event, helper) {
        helper.getCandidateResultList(component);
    },
    searchKeyChange: function(component, event) {
        var searchKey = component.find("searchKey").get("v.value");
        console.log('searchKey:::::'+searchKey);
        var action = component.get("c.findByName");
        action.setParams({
            "searchKey": searchKey
        });
        action.setCallback(this, function(a) {
            component.set("v.candidateresults", a.getReturnValue());
        });
        $A.enqueueAction(action);
    }   
})
