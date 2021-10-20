({
	doInitHelper : function(component, event, helper) {
        var action = component.get("c.getRecord");
        action.setParams({ assetId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                component.set("v.recordData",response.getReturnValue());
                component.set("v.showSpinner",false);
            }
            else if (state === "INCOMPLETE") 
            {
                console.log('INCOMPLETE');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } 
                    else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
	},
})