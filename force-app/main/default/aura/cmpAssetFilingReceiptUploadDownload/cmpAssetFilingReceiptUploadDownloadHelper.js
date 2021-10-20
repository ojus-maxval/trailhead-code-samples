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
    updateHelper : function(component, event, helper, uploadedFileId) {
        var action = component.get("c.updateRecord");
        action.setParams({ assetId : component.get("v.recordId"), fileId : uploadedFileId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if (state === "SUCCESS") 
            {
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": "The record has been updated successfully."
                });
                component.set("v.showSpinner",false);
                component.set("v.recordData",response.getReturnValue());
                this.doInitHelper(component, event, helper);
            }
            else if (state === "INCOMPLETE") 
            {
                console.log('INCOMPLETE');
                
            }
                else if (state === "ERROR") {
                    
                    var errors = response.getError();
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error",
                        "message": response.getReturnValue()
                    });
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
            toastEvent.fire();
            $A.get('e.force:refreshView').fire();   
        });
        $A.enqueueAction(action);
    },
    deleteFileHelper : function(component, event, helper, uploadedFileId) {
        var mydata = component.get("v.recordData");
		
        var action = component.get("c.deleteFileRecord");
        action.setParams({ assetId : component.get("v.recordId"), fileId : mydata.fileId, fileDocId:mydata.fileConDocId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if (state === "SUCCESS") 
            {
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": "The file has been deleted & updated record successfully."
                });
                component.set("v.showSpinner",false);
                component.set("v.recordData",response.getReturnValue());
                this.doInitHelper(component, event, helper);
            }
            else if (state === "INCOMPLETE") 
            {
                console.log('INCOMPLETE');
                
            }
                else if (state === "ERROR") {
                    
                    var errors = response.getError();
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error",
                        "message": response.getReturnValue()
                    });
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
            toastEvent.fire();
            $A.get('e.force:refreshView').fire();   
        });
        $A.enqueueAction(action);
    },
})