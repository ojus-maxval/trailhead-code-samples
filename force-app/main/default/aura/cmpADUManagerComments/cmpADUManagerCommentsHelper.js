({
	doInitHelper : function(component, event, helper) {
		//cmp.get("v.afterCreateWrapper",null);
		var action = component.get("c.getRecords");
        action.setParams({ assetId : component.get("v.recordId")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") 
            {
                component.set("v.vComments",response.getReturnValue());
                component.set("v.vNewComments",'');
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
    updateHelper : function(component, event, helper) {
        var action = component.get("c.updateRecords");
        action.setParams({ assetId : component.get("v.recordId"), cmts : component.get("v.vComments"), newCmts : component.get("v.vNewComments")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") 
            {
                var toastEvent = $A.get("e.force:showToast");
                //var editRecordEvent = $A.get("e.force:editRecord");
                if(response.getReturnValue() == 'Success')
                {
                    toastEvent.setParams({
                        "type": "success",
                        "title": "Success!",
                        "message": "The record has been updated successfully."
                    });
                    component.set("v.vNewComments",'');
                    
                }
                else
                {
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error",
                        "message": response.getReturnValue()
                    });
                }
                this.doInitHelper(component, event, helper);
                //editRecordEvent.fire();
                toastEvent.fire();
				$A.get('e.force:refreshView').fire();                
                
            }
            else if (state === "INCOMPLETE") 
            {
                console.log('INCOMPLETE');
                
            }
                else if (state === "ERROR") {
                    
                    var errors = response.getError();
                    if(actionType)
                    {
                        //component.set("v.respOnPTO",errors[0].message);
                    }
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