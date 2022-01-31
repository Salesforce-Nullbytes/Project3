//({
//    helperMethod : function() {

//    }
//})

({      
    getPassPercentagetList: function(component) {
        var action = component.get('c.getPassPercentages');
        var self = this;
        action.setCallback(this, function(actionResult) {
            component.set('v.passpercentages', actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})
