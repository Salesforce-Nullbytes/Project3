//({
 //   helperMethod : function() {

 //   }
//})
({      
    getCandidateResultList: function(component) {
        var action = component.get('c.getCandidateResults');
        var self = this;
        action.setCallback(this, function(actionResult) {
            component.set('v.candidateresults', actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})
